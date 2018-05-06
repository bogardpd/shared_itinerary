class FlightsController < ApplicationController
  before_action :logged_in_user, only: [:new, :create, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update, :destroy]
  
  def new
    @traveler = Traveler.find(params[:traveler])
    @flight = Flight.new
    @timezone = @traveler.is_arrival? ? @traveler.event.arriving_timezone : @traveler.event.departing_timezone
    session[:current_traveler] = @traveler.id
    
    rescue ActiveRecord::RecordNotFound
      redirect_to current_user
  end
  
  def create
    convert_iata_codes_to_ids
    
    current_traveler = Traveler.find(session[:current_traveler])
    @flight = current_traveler.flights.build(flight_params)
    if @flight.save
      flash[:success] = "Flight created! #{view_context.link_to("Jump to this flight’s itinerary", "#s-#{current_traveler.id}", class: "btn btn-default")} #{view_context.link_to(%Q[<span class="glyphicon glyphicon-plus"></span> <span class="glyphicon glyphicon-plane"></span>&ensp;Add another flight].html_safe, new_flight_path(traveler: current_traveler.id), class: "btn btn-default")}"
      redirect_to event_path(current_traveler.event)
    else
      @timezone = current_traveler.is_arrival? ? current_traveler.event.arriving_timezone : current_traveler.event.departing_timezone
      render 'new'
    end
  end
  
  def edit
    @flight= Flight.find(params[:id])
    @timezone = @flight.traveler.is_arrival? ? @flight.traveler.event.arriving_timezone :  @flight.traveler.event.departing_timezone
  end
  
  def update
    convert_iata_codes_to_ids
    
    @flight = Flight.find(params[:id])
    if @flight.update_attributes(flight_params)
      flash[:success] = "Flight updated! #{view_context.link_to("Jump to this flight’s itinerary", "#s-#{@flight.traveler.id}", class: "btn btn-default")}"
      redirect_to @flight.traveler.event
    else
      @timezone = @flight.traveler.is_arrival? ? @flight.traveler.event.arriving_timezone :  @flight.traveler.event.departing_timezone
      render 'edit'
    end
  end
  
  def destroy
    @flight = Flight.find(params[:id])
    current_event = @flight.traveler.event
    @flight.destroy
    flash[:success] = "Flight deleted! #{view_context.link_to("Jump to the deleted flight’s itinerary", "#s-#{@flight.traveler.id}", class: "btn btn-default")}"
    redirect_to current_event
  end
  
  private
  
    def flight_params
      params.require(:flight).permit(:airline_id, :flight_number, :departure_datetime, :departure_airport_id, :arrival_datetime, :arrival_airport_id, :is_arrival)
    end
    
    def correct_user
      redirect_to root_url if Flight.find(params[:id]).traveler.event.user != current_user
    end
    
    def convert_iata_codes_to_ids
      params[:flight][:airline_id] = Airline.find_or_create_by!(:iata_code => params[:flight][:airline_iata].upcase).id
      params[:flight][:departure_airport_id] = Airport.find_or_create_by!(:iata_code => params[:flight][:dep_airport_iata].upcase).id
      params[:flight][:arrival_airport_id] = Airport.find_or_create_by!(:iata_code => params[:flight][:arr_airport_iata].upcase).id
    end
  
end
