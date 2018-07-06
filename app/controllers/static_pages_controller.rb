class StaticPagesController < ApplicationController
  before_action :admin_user, only: [:admin]
  
  def home
    redirect_to current_user if logged_in?
  end
  
  def admin
    
  end
  
  def letsencrypt
    render plain: ENV["LETS_ENCRYPT_KEY"]
  end

  # Interacts with Google Places API on behalf of in-page scripts to avoid
  # sharing the API key with client-side scripts
  def google_places_api_proxy
    require "net/http"
    if params[:term]
      url = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=#{URI.encode(params[:term])}&types=(cities)&key=#{ENV["GOOGLE_MAPS_API_KEY"]}"
      uri = URI(url)
      response = JSON.parse(Net::HTTP.get(uri))
      render json: response["predictions"].map{|r| r["description"]}.to_json
    else
      render json: {}
    end
  end
 
end
