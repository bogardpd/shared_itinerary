class TravelersController < ApplicationController
  before_action :logged_in_user, only: [:new, :create, :edit, :destroy]
  before_action :correct_user, only: [:create, :edit, :destroy]
  
  def new
    @traveler = Event.find(params[:event]).travelers.build
  end
  
  def create
    current_event = Event.find(params[:traveler][:event])
    @traveler = current_event.travelers.build(traveler_params)
    if @traveler.save
      flash[:success] = "Itinerary created! #{view_context.link_to("Jump to this itinerary", "#s-#{@traveler.id}", class: "btn btn-default")} #{view_context.link_to(%Q[<span class="glyphicon glyphicon-plus"></span> <span class="glyphicon glyphicon-plane"></span>&ensp;Add a flight].html_safe, new_flight_path(traveler: @traveler.id), class: "btn btn-default")}"
      redirect_to event_path(current_event)
    else
      render 'static_pages/home'
    end
  end
  
  def edit
    @traveler = Traveler.find(params[:id])
  end
  
  def update
    @traveler = Traveler.find(params[:id])
    if @traveler.update_attributes(traveler_params)
      flash[:success] = "Traveler info updated! #{view_context.link_to("Jump to this traveler’s itinerary", "#s-#{@traveler.id}", class: "btn btn-default")}"
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
    if params[:id] # edit
      event_user = Traveler.find(params[:id]).event.user
    elsif params[:event]
      event_user = Event.find(params[:event]).user
    else
      event_user = Event.find(params[:traveler][:event]).user
    end
    redirect_to root_url if event_user != current_user
  end
  
end
