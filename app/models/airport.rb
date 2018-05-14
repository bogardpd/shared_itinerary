class Airport < ActiveRecord::Base
  has_many :origin_flights,      class_name: "Flight", foreign_key: "origin_airport_id"
  has_many :destination_flights, class_name: "Flight", foreign_key: "destination_airport_id"
  
  before_save { self.iata_code = iata_code.upcase }
  validates :iata_code, presence: true,
                        length: { is: 3 },
                        uniqueness: { case_sensitive: false }
  validates :timezone, presence: true
                        
  def formatted_name
    self.name ? "#{self.name} (#{self.iata_code})" : self.iata_code
  end
  
  def formatted_iata
    self.iata_code ? self.iata_code : ""
  end
  
  def self.airport_names
    return Airport.all.map{ |a| [a.iata_code, a.formatted_name] }.to_h
  end
  
  # Attempts to find an airport with the supplied IATA code. If none exists,
  # attempts to create it and return the new airport.
  def self.find_or_create_by_iata(iata_code)
    return nil unless iata_code && iata_code.length == 3
    if airport = Airport.find_by(iata_code: iata_code.upcase)
      return airport
    else
      # lookup timezone/name on FlightXML
      return nil
    end
  end
  
end
