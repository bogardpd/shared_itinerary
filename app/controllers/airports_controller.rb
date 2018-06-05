class AirportsController < ApplicationController
  before_action :logged_in_user
  before_action :admin_user
  
  def index
    @airports = Airport.order({needs_review: :desc}, :name, :iata_code, :icao_code)
  end
  
  def new
    @airport = Airport.new
  end
  
  def create
    @airport = Airport.new(airport_params)
    if @airport.save
      flash[:success] = "Successfully created #{@airport.iata_code}!"
      redirect_to airports_path
    else
      render 'new'
    end
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
      params.require(:airport).permit(:iata_code, :icao_code, :name, :timezone, :needs_review)
    end
  
end
