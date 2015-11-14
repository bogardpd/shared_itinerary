class EventsController < ApplicationController
  before_action :logged_in_user, only: [:new, :create, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update, :destroy]
  
  def show
    @event = Event.find(params[:id])
  end
  
  def new
    @event = current_user.events.build
  end
  
  def create
    @event = current_user.events.build(event_params)
    if @event.save
      flash[:success] = "Event created!"
      redirect_to user_path(current_user)
    else
      render 'static_pages/home'
    end
  end
  
  def edit
    @event = Event.find(params[:id])
  end
  
  def update
    if @event.update_attributes(event_params)
      flash[:success] = "Event updated!"
      redirect_to @event
    else
      render 'edit'
    end
  end
  
  def destroy
    @event.destroy
    flash[:success] = "Event deleted!"
    redirect_to user_path(current_user)
  end
  
  private
  
    def event_params
      params.require(:event).permit(:event_name, :arriving_timezone, :departing_timezone)
    end
    
    def correct_user
      @event = current_user.events.find_by(id: params[:id])
      redirect_to root_url if @event.nil?
    end
  
end
