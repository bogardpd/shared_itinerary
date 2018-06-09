class AirlinesController < ApplicationController
  before_action :logged_in_user
  before_action :admin_user
  
  def index
    @airlines = Airline.all.sort_by{|a| [a.needs_review ? -1 : 0, a.name&.downcase || "", a.iata_code || "", a.icao_code || ""]}
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
      params.require(:airline).permit(:iata_code, :icao_code, :name, :needs_review)
    end
    
end
