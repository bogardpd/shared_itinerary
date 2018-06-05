class Airline < ActiveRecord::Base
  has_many :flights
  before_save :upcase_airline_codes
  validates :iata_code, presence: true,
                        length: { is: 2 },
                        uniqueness: { case_sensitive: false }
  
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
