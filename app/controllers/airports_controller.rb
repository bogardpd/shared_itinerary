class AirportsController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update]
  before_action :admin_user, only: [:index, :edit, :update]
  
  def index
    @airports = Airport.all.order(:name, :iata_code)
  end
  
  def edit
    @airport = Airport.find(params[:id])
  end
  
  def update
    @airport = Airport.find(params[:id])
    if @airport.update_attributes(airport_params)
      flash[:success] = "Airport updated!"
      redirect_to airports_path
    else
      render 'edit'
    end
  end
  
  private
  
    def airport_params
      params.require(:airport).permit(:iata_code, :name)
    end
  
end
