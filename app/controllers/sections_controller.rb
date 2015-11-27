class SectionsController < ApplicationController
  before_action :logged_in_user, only: [:new, :create]
  before_action :correct_user, only: [:create]
  
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
    event_user = Event.find(params[:event]).user
    #write code to save itinerary
    redirect_to user_path(event_user)
  end
  
  private
    
  def correct_user
    event_user = Event.find(params[:event]).user
    redirect_to root_url if event_user != current_user
  end
  
end
