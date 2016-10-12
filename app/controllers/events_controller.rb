class EventsController < ApplicationController
  before_action :logged_in_user, only: [:new, :create, :edit, :update, :share_link, :destroy]
  before_action :correct_user, only: [:edit, :update, :share_link, :destroy]
  before_action :correct_user_or_share_link, only: [:show]
  
  def show
    @event = Event.find(params[:id])
    @chart = @event.chart
    @share_link = url_for(share_link: @event.share_link)
        
    rescue ActiveRecord::RecordNotFound
      flash[:warning] = "We couldnʼt find an event with an ID of #{params[:id]}."
      redirect_to current_user
      
  end
  
  def new
    @event = current_user.events.build
  end
  
  def create
    @event = current_user.events.build(event_params.merge(share_link: SecureRandom.hex(8)))
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
  
  def update_share_link
    share_text = SecureRandom.hex(8)
    @event = Event.find(params[:id])
    @event.update_attributes(share_link: share_text)
    redirect_to @event
    
    rescue ActiveRecord::RecordNotFound
      flash[:warning] = "We couldnʼt find an event with an ID of #{params[:id]}."
      redirect_to current_user
  end
  
  def destroy
    @event.destroy
    flash[:success] = "Event deleted!"
    redirect_to user_path(current_user)
  end
  
  private
  
    def event_params
      params.require(:event).permit(:event_name, :timezone, :arriving_timezone, :departing_timezone, :note)
    end
    
    def correct_user
      @event = current_user.events.find_by(id: params[:id])
      redirect_to root_url if @event.nil?
    end
    
    def correct_user_or_share_link
      if params[:share_link].nil? || params[:share_link] != Event.find(params[:id]).share_link
        if logged_in?
          correct_user
        else
          store_location
          flash[:danger] = "Please log in."
          redirect_to login_url
        end
      end
    end
  
end
