class FlightsController < ApplicationController
  before_action :logged_in_user, only: [:new, :create, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update, :destroy]
  
  def new
    @section = Section.find(params[:section])
    @flight = Flight.new
    @timezone = @section.is_arrival? ? @section.event.arriving_timezone : @section.event.departing_timezone
    session[:current_section] = @section.id
    
    rescue ActiveRecord::RecordNotFound
      redirect_to current_user
  end
  
  def create
    convert_iata_codes_to_ids
    
    current_section = Section.find(session[:current_section])
    @flight = current_section.flights.build(flight_params)
    if @flight.save
      flash[:success] = "Flight created! #{view_context.link_to("Jump to this flight’s itinerary", "#s-#{current_section.id}", class: "btn btn-default")} #{view_context.link_to(%Q[<span class="glyphicon glyphicon-plus"></span> <span class="glyphicon glyphicon-plane"></span>&ensp;Add another flight].html_safe, new_flight_path(section: current_section.id), class: "btn btn-default")}"
      redirect_to event_path(current_section.event)
    else
      @timezone = current_section.is_arrival? ? current_section.event.arriving_timezone : current_section.event.departing_timezone
      render 'new'
    end
  end
  
  def edit
    @flight= Flight.find(params[:id])
    @timezone = @flight.section.is_arrival? ? @flight.section.event.arriving_timezone :  @flight.section.event.departing_timezone
  end
  
  def update
    convert_iata_codes_to_ids
    
    @flight = Flight.find(params[:id])
    if @flight.update_attributes(flight_params)
      flash[:success] = "Flight updated! #{view_context.link_to("Jump to this flight’s itinerary", "#s-#{@flight.section.id}", class: "btn btn-default")}"
      redirect_to @flight.section.event
    else
      @timezone = @flight.section.is_arrival? ? @flight.section.event.arriving_timezone :  @flight.section.event.departing_timezone
      render 'edit'
    end
  end
  
  def destroy
    @flight = Flight.find(params[:id])
    current_event = @flight.section.event
    @flight.destroy
    flash[:success] = "Flight deleted! #{view_context.link_to("Jump to the deleted flight’s itinerary", "#s-#{@flight.section.id}", class: "btn btn-default")}"
    redirect_to current_event
  end
  
  private
  
    def flight_params
      params.require(:flight).permit(:airline_id, :flight_number, :departure_datetime, :departure_airport_iata, :departure_airport_id, :arrival_datetime, :arrival_airport_iata, :arrival_airport_id)
    end
    
    def correct_user
      redirect_to root_url if Flight.find(params[:id]).section.event.user != current_user
    end
    
    def convert_iata_codes_to_ids
      params[:flight][:airline_id] = Airline.find_or_create_by!(:iata_code => params[:flight][:airline_iata].upcase).id
      params[:flight][:departure_airport_id] = Airport.find_or_create_by!(:iata_code => params[:flight][:departure_airport_iata].upcase).id
      params[:flight][:arrival_airport_id] = Airport.find_or_create_by!(:iata_code => params[:flight][:arrival_airport_iata].upcase).id
    end
  
end
