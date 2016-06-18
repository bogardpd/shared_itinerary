class EventsController < ApplicationController
  before_action :logged_in_user, only: [:new, :create, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update, :destroy]
  
  def show
    @event = Event.find(params[:id])
    @arrivals = @event.sections.where(is_arrival: true)
    @departures = @event.sections.where(is_arrival: false)
    
    #@arrive_list = Hash.new
    #@depart_list = Hash.new
    
    @incoming_flights = section_array(@arrivals)
    @returning_flights = section_array(@departures)
    
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
    def section_array(sections_collection)
      flights_array = Array.new
      sections_collection.each do |section|
        flights = Array.new
        section.flights.order(:departure_datetime).each do |flight|
          flights.push([flight.airline_iata,
                        flight.flight_number,
                        flight.departure_airport_iata,
                        flight.departure_datetime,
                        flight.arrival_airport_iata,
                        flight.arrival_datetime])
        end
        flights_array.push([ section.traveler_name, flights ])
      end
      return flights_array
    end
  
end
