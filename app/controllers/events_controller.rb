class EventsController < ApplicationController
  before_action :logged_in_user, only: [:new, :create, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update, :destroy]
  
  def show
    @event = Event.find(params[:id])
    @arrivals = @event.sections.where(is_arrival: true)
    @departures = @event.sections.where(is_arrival: false)
    
    @flights = [section_array(@arrivals, true), section_array(@departures, false)]
    @timezones = [@event.arriving_timezone, @event.departing_timezone]
    
    # Generate hues:
    
    key_airports = Set.new
    @row_hue = Hash.new
    
    @flights.each do |flight|
      flight.each do |section|
        key_airports.add(section[:key_airport])
      end
    end
    hue_step = 360/key_airports.length
    key_airports.each_with_index do |airport, index|
      @row_hue[airport] = index*hue_step
    end
      
    rescue ActiveRecord::RecordNotFound
      flash[:warning] = "We couldnʼt find an event with an ID of #{params[:id]}."
      redirect_to current_user
  end
  
  def new
    @event = current_user.events.build
  end
  
  def create
    @event = current_user.events.build(event_params)
    if @event.save
      flash[:success] = "Event created!"
      redirect_to user_path(current_user)
    else
      render 'static_pages/home'
    end
  end
  
  def edit
    @event = Event.find(params[:id])
  end
  
  def update
    if @event.update_attributes(event_params)
      flash[:success] = "Event updated!"
      redirect_to @event
    else
      render 'edit'
    end
  end
  
  def destroy
    @event.destroy
    flash[:success] = "Event deleted!"
    redirect_to user_path(current_user)
  end
  
  private
  
    def event_params
      params.require(:event).permit(:event_name, :arriving_timezone, :departing_timezone)
    end
    
    def correct_user
      @event = current_user.events.find_by(id: params[:id])
      redirect_to root_url if @event.nil?
    end
    
    # Accepts a collection of trip sections and formats them in an array.
    def section_array(sections_collection, is_arrival)
      flights_array = Array.new
      sections_collection.each do |section|
        flights = Array.new
        section.flights.order(:departure_datetime).each do |flight|
          flights.push({
            airline:           flight.airline_iata,
            flight_number:     flight.flight_number,
            departure_airport: flight.departure_airport_iata,
            departure_time:    flight.departure_datetime,
            arrival_airport:   flight.arrival_airport_iata,
            arrival_time:      flight.arrival_datetime
          })
        end
        key_airport = is_arrival ? flights.last[:arrival_airport] : flights.first[:departure_airport]
        flights_array.push({
          name:                   section.traveler_name,
          nickname:               section.traveler_note, 
          flights:                flights,
          section_departure_time: flights.first[:departure_time],
          section_arrival_time:   flights.last[:arrival_time],
          key_airport:            key_airport 
        })  
      end
      
      if is_arrival
        flights_array.sort_by! { |h| [h[:section_arrival_time], h[:section_departure_time]] }
      else
        flights_array.sort_by! { |h| [h[:section_departure_time], h[:section_arrival_time]] }
      end
      
      return flights_array
    end
  
end
