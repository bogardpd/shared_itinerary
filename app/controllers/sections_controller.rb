class SectionsController < ApplicationController

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
  
end
