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
      flash[:success] = "Flight created!"
      redirect_to event_path(current_section.event)
    else
      render 'static_pages/home'
    end
  end
  
  private
  
    def flight_params
      params.require(:flight).permit(:airline_iata, :flight_number, :departure_datetime, :departure_airport_iata, :arrival_datetime, :arrival_airport_iata)
    end
    
    def correct_user
      @flight = current_user.events.flights.find_by(id: params[:id])
      redirect_to root_url if @flight.nil?
    end
  
end
