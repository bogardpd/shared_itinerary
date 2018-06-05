class AirlinesController < ApplicationController
  before_action :logged_in_user
  before_action :admin_user
  
  def index
    @airlines = Airline.all.order(:name, :iata_code)
  end
  
  def edit
    @airline = Airline.find(params[:id])
  end
  
  def update
    @airline = Airline.find(params[:id])
    if @airline.update_attributes(airline_params)
      flash[:success] = "Airline updated!"
      redirect_to airlines_path
    else
      render 'edit'
    end
  end
  
  private
  
    def airline_params
      params.require(:airline).permit(:iata_code, :name, :needs_review)
    end
    
end
