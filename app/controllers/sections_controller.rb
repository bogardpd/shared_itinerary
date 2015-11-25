class SectionsController < ApplicationController

  def new
    @section = Event.find(params[:event]).sections.build
  end
  
end
