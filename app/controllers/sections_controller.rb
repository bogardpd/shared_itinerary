class SectionsController < ApplicationController
  before_action :logged_in_user, only: [:new, :create, :edit, :destroy]
  before_action :correct_user, only: [:create, :edit, :destroy]
  
  def new
    @section = Event.find(params[:event]).sections.build
    case params[:direction]
    when "arrival"
      @title_text = "Add a New Arrival Itinerary"
      @to_from_text = "from"
      @is_arrival = true
      @show_arrival_departure = false
    when "departure"
      @title_text = "Add a New Departure Itinerary"
      @to_from_text = "to"
      @is_arrival = false
      @show_arrival_departure = false
    else
      @title_text = "Add a New Itinerary"
      @to_from_text = "to/from"
      @show_arrival_departure = true
    end
  end
  
  def create
    current_event = Event.find(params[:section][:event])
    @section = current_event.sections.build(section_params)
    if @section.save
      flash[:success] = "Itinerary created!"
      redirect_to event_path(current_event)
    else
      render 'static_pages/home'
    end
  end
  
  def edit
    @section = Section.find(params[:id])
  end
  
  def update
    @section = Section.find(params[:id])
    if @section.update_attributes(section_params)
      flash[:success] = "Traveler info updated!"
      redirect_to @section.event
    else
      render 'edit'
    end
  end
  
  def destroy
    @section = Section.find(params[:id])
    current_event = @section.event
    @section.destroy
    flash[:success] = "Itinerary deleted!"
    redirect_to current_event
  end
  
  private
  
  def section_params
    params.require(:section).permit(:traveler_name, :traveler_note, :pickup_info, :is_arrival)
  end
    
  def correct_user
    if params[:id] # edit
      event_user = Section.find(params[:id]).event.user
    elsif params[:event]
      event_user = Event.find(params[:event]).user
    else
      event_user = Event.find(params[:section][:event]).user
    end
    redirect_to root_url if event_user != current_user
  end
  
end
