class FlightsController < ApplicationController
  before_action :logged_in_user, only: [:new, :create, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update, :destroy]
  
  def new
    @traveler = Traveler.find(params[:traveler])
    @flight = Flight.new
    @timezone = @traveler.event.timezone
    session[:current_traveler] = @traveler.id
    
    rescue ActiveRecord::RecordNotFound
      redirect_to current_user
  end
  
  def create
    convert_iata_codes_to_ids

    params[:flight][:origin_airport_id]      = Airport.find_or_create_by_iata(params[:flight][:origin_airport_iata])&.id
    params[:flight][:destination_airport_id] = Airport.find_or_create_by_iata(params[:flight][:destination_airport_iata])&.id
    current_traveler = Traveler.find(session[:current_traveler])
    @flight = current_traveler.flights.build(flight_params)
    
    if params[:flight][:origin_airport_id] && params[:flight][:destination_airport_id]
      if @flight.save
        flash[:success] = "Flight created! #{view_context.link_to("Jump to this flight’s itinerary", "#s-#{current_traveler.id}", class: "btn btn-default")} #{view_context.link_to(%Q[<span class="glyphicon glyphicon-plus"></span> <span class="glyphicon glyphicon-plane"></span>&ensp;Add another flight].html_safe, new_flight_path(traveler: current_traveler.id), class: "btn btn-default")}"
        redirect_to event_path(current_traveler.event)
      else
        render "new"
      end
    else
      if current_user.admin?
        unknown_airports = Array.new
        unknown_airports.push(params[:flight][:origin_airport_iata]&.upcase) unless params[:flight][:origin_airport_id]
        unknown_airports.push(params[:flight][:destination_airport_iata]&.upcase) unless params[:flight][:destination_airport_id]
        flash.now[:warning] = "We couldn't automatically look up some new airport names and time zones (#{unknown_airports.join(", ")}). You can try again later, or #{view_context.link_to("manually create airports", new_airport_path)}."
        render "new"
      else
        flash.now[:danger] = "Something went wrong when we tried to look up your airport codes. The problem might be on our end, but please check that your airport codes are correct, or try again later."
        render "new"
      end
    end
  end
  
  def edit
    @flight = Flight.find(params[:id])
    @timezone = @flight.traveler.event.timezone
  end
  
  def update
    convert_iata_codes_to_ids
    
    @flight = Flight.find(params[:id])
    if @flight.update_attributes(flight_params)
      flash[:success] = "Flight updated! #{view_context.link_to("Jump to this flight’s itinerary", "#s-#{@flight.traveler.id}", class: "btn btn-default")}"
      redirect_to @flight.traveler.event
    else
      @timezone = @flight.traveler.event.timezone
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
      params.require(:flight).permit(:airline_id, :flight_number, :origin_time, :origin_airport_id, :destination_time, :destination_airport_id, :is_event_arrival)
    end
    
    def correct_user
      redirect_to root_url if Flight.find(params[:id]).traveler.event.user != current_user
    end
    
    def convert_iata_codes_to_ids
      params[:flight][:airline_id] = Airline.find_or_create_by!(:iata_code => params[:flight][:airline_iata].upcase).id
      params[:flight][:origin_airport_id]      = Airport.find_or_create_by_iata(params[:flight][:origin_airport_iata])&.id
      params[:flight][:destination_airport_id] = Airport.find_or_create_by_iata(params[:flight][:destination_airport_iata])&.id
      
    end
    
    
  
end
