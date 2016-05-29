class FlightsController < ApplicationController
  before_action :logged_in_user, only: [:new, :create, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update, :destroy]
  
  def new
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
