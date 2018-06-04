class FlightsController < ApplicationController
  before_action :logged_in_user,   only: [:new, :create, :edit, :update, :destroy]
  before_action :correct_traveler, only: [:new, :create]
  before_action :correct_user,     only: [:edit, :update, :destroy]
  
  def new
    @traveler = Traveler.find(params[:traveler])
    @event = @traveler.event
    @flight = Flight.new
    
    rescue ActiveRecord::RecordNotFound
      redirect_to current_user
  end
  
  def create
    @traveler = Traveler.find(params[:flight][:traveler_id])
    @flight = @traveler.flights.build(flight_params)

    if @flight.save
      flash[:success] = "Flight created! #{view_context.link_to("Jump to this flight’s itinerary", "#t-#{@traveler.id}", class: "btn btn-success")} #{view_context.link_to("Add another flight", new_flight_path(traveler: @traveler.id), class: "btn btn-success")}"
      session[:current_traveler] = nil
      redirect_to event_path(@traveler.event)
    else
      @event = @traveler.event
      render "new"
    end
    
  end
  
  def create_from_flight_xml
    render plain: params
    # add to logged_in and correct_traveler check
  end
  
  def edit
    @flight = Flight.find(params[:id])
    @traveler = @flight.traveler
    @event = @traveler.event
  end
  
  def update
    @flight = Flight.find(params[:id])

    if @flight.update_attributes(flight_params)
      flash[:success] = "Flight updated! #{view_context.link_to("Jump to this flight’s itinerary", "#t-#{@flight.traveler.id}", class: "btn btn-success")}"
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
    flash[:success] = "Flight deleted! #{view_context.link_to("Jump to the deleted flight’s itinerary", "#t-#{@flight.traveler.id}", class: "btn btn-success")}"
    redirect_to current_event
  end
  
  private
  
    def flight_params
      params.require(:flight).permit(:flight_number, :origin_time, :destination_time, :is_event_arrival, airline_attributes: [:iata_code], origin_airport_attributes: [:iata_code], destination_airport_attributes: [:iata_code])
    end
    
    def correct_user
      redirect_to root_url if Flight.find(params[:id]).traveler.event.user != current_user
    end
    
    def correct_traveler
      if params[:flight] && params[:flight][:traveler_id]
        traveler = params[:flight][:traveler_id]
      else
        traveler = params[:traveler]
      end
      redirect_to root_url if traveler.nil?
      redirect_to root_url if Traveler.find(traveler)&.event&.user != current_user
    end
  
end
