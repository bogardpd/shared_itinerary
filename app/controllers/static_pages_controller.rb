class StaticPagesController < ApplicationController
  before_action :admin_user, only: [:admin]
  before_action :logged_in_user, only: [:google_places_api_proxy, :google_timezone_api_proxy]
  
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
      url = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=#{URI.encode(params[:term])}&types=(cities)&key=#{ENV["GOOGLE_MAPS_API_KEY"]}&sessiontoken=#{params[:google_session]}"
      uri = URI(url)
      response = JSON.parse(Net::HTTP.get(uri))
      render json: response["predictions"].map{|r| {label: r["description"], value: r["place_id"]}}.to_json
    else
      render json: {}
    end
  end

  # Interacts with Google Time Zone API on behalf of in-page scripts to avoid
  # sharing the API key with client-side scripts
  def google_timezone_api_proxy
    require "net/http"
    if params[:place_id]
      url = "https://maps.googleapis.com/maps/api/place/details/json?placeid=#{params[:place_id]}&fields=geometry&key=#{ENV["GOOGLE_MAPS_API_KEY"]}&sessiontoken=#{params[:google_session]}"
      uri = URI(url)
      response = JSON.parse(Net::HTTP.get(uri))
      if response["result"]
        latitude  = response.dig("result", "geometry", "location", "lat")
        longitude = response.dig("result", "geometry", "location", "lng")
        tz_url = "https://maps.googleapis.com/maps/api/timezone/json?location=#{latitude},#{longitude}&timestamp=#{Time.now.to_i}&key=#{ENV["GOOGLE_MAPS_API_KEY"]}"
        tz_uri = URI(tz_url)
        tz_response = Net::HTTP.get(tz_uri)
        render json: tz_response
      else
        render json: {}
      end
    else
      render json: {}
    end
  end
 
end
