class Airline < ActiveRecord::Base
  has_many :flights
  before_save :upcase_airline_codes
  validates :iata_code, length: { is: 2 }, allow_blank: true
  validates :icao_code, length: { is: 3 }, allow_blank: true, uniqueness: { case_sensitive: false }
  
  def code
    return self.iata_code if self.iata_code.present?
    return self.icao_code if self.icao_code.present?
    return ""
  end
  
  def formatted_name
    self.name ? self.name : self.iata_code
  end
  
  # Accepts an airline IATA code and returns an image path (if the image
  # exists) or nil (if it does not)
  def self.icon_path(airline_iata)
    return "#{ExternalImage::ROOT_PATH}/flights/airline-icons/#{airline_iata.upcase}.png"
  end
  
  private
  
  def upcase_airline_codes
    self.iata_code = iata_code.upcase
    self.icao_code = icao_code.upcase
  end
  
end
