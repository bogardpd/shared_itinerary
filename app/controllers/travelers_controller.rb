class TravelersController < ApplicationController
  before_action :logged_in_user, only: [:new, :new_flight_search, :new_flight_select, :create, :edit, :destroy]
  before_action :correct_user, only: [:new, :new_flight_search, :new_flight_select, :create, :edit, :destroy]
  
  def new
    @event = Event.find(params[:event])
    @traveler = @event.travelers.build
  end
  
  def new_flight_search
    @traveler = Traveler.find(params[:id])
    @event = @traveler.event
  end
  
  def new_flight_select
    @traveler = Traveler.find(params[:id])
    @event = @traveler.event
    @flight = Flight.new(traveler: @traveler)
    
    if params[:airline_code].blank? || params[:flight_number].blank? || params[:departure_date].blank?
      flash.now[:danger] = "Some form fields are blank!"
      render "new_flight_search"
      return
    end
    
    @matching_flights = FlightXML::matching_flights(params[:airline_code]&.upcase, params[:flight_number], Date.parse(params[:departure_date]))
    @direction = params[:is_event_arrival] == "true" ? "arrival" : "departure"

    unless @matching_flights.any?
      flash[:info] = "We couldn’t automatically look up #{params[:airline_code].upcase} #{params[:flight_number]} on #{view_context.short_date(Date.parse(params[:departure_date]))}. Please enter your flight details."
      redirect_to new_flight_path(traveler: @traveler.id, direction: @direction)
    end
    
  end
  
  def create
    current_event = Event.find(params[:traveler][:event])
    @traveler = current_event.travelers.build(traveler_params)
    if @traveler.save
      flash[:success] = "Itinerary created! #{view_context.link_to("Jump to this itinerary", "#t-#{@traveler.id}", class: "btn btn-success")} #{view_context.link_to("Add a flight", new_flight_path(traveler: @traveler.id), class: "btn btn-success")}"
      redirect_to event_path(current_event)
    else
      render 'static_pages/home'
    end
  end
  
  def edit
    @traveler = Traveler.find(params[:id])
    @event = @traveler.event
  end
  
  def update
    @traveler = Traveler.find(params[:id])
    if @traveler.update_attributes(traveler_params)
      flash[:success] = "Traveler info updated! #{view_context.link_to("Jump to this traveler’s itinerary", "#t-#{@traveler.id}", class: "btn btn-success")}"
      redirect_to @traveler.event
    else
      render 'edit'
    end
  end
  
  def destroy
    @traveler = Traveler.find(params[:id])
    current_event = @traveler.event
    @traveler.destroy
    flash[:success] = "Itinerary deleted!"
    redirect_to current_event
  end
  
  private
  
  def traveler_params
    params.require(:traveler).permit(:traveler_name, :traveler_note, :arrival_info, :departure_info)
  end
    
  def correct_user
    if params[:id]
      event_user = Traveler.find(params[:id]).event.user
    elsif params[:event]
      event_user = Event.find(params[:event]).user
    else
      event_user = Event.find(params[:traveler][:event]).user
    end
    redirect_to root_url if event_user != current_user
  end
  
end
