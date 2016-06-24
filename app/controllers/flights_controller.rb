class FlightsController < ApplicationController
  before_action :logged_in_user, only: [:new, :create, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update, :destroy]
  
  def new
    @section = Section.find(params[:section])
    @flight = Flight.new
    @timezone = @section.is_arrival? ? @section.event.arriving_timezone : @section.event.departing_timezone
    session[:current_section] = @section.id
  end
  
  def create
    current_section = Section.find(session[:current_section])
    @flight = current_section.flights.build(flight_params)
    if @flight.save
      flash[:success] = "Flight created! Would you like to <a href=\"#s-#{current_section.id}\">jump to this flight’s itinerary</a>?"
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
    @flight = Flight.find(params[:id])
    if @flight.update_attributes(flight_params)
      flash[:success] = "Flight updated! Would you like to <a href=\"#s-#{@flight.section.id}\">jump to this flight’s itinerary</a>?"
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
    flash[:success] = "Flight deleted!"
    redirect_to current_event
  end
  
  private
  
    def flight_params
      params.require(:flight).permit(:airline_iata, :flight_number, :departure_datetime, :departure_airport_iata, :arrival_datetime, :arrival_airport_iata)
    end
    
    def correct_user
      redirect_to root_url if Flight.find(params[:id]).section.event.user != current_user
    end
  
end
