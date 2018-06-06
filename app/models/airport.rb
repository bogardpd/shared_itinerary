class Airport < ActiveRecord::Base
  has_many :origin_flights,      class_name: "Flight", foreign_key: "origin_airport_id"
  has_many :destination_flights, class_name: "Flight", foreign_key: "destination_airport_id"
  
  before_save :upcase_airport_codes
  validates :iata_code, length: { is: 3 }, allow_blank: true
  validates :icao_code, length: { is: 4 }, allow_blank: true, uniqueness: { case_sensitive: false }
  validates :timezone, presence: true
  
  def code
    return self.iata_code if self.iata_code.present?
    return self.icao_code if self.icao_code.present?
    return ""
  end
                        
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
    iata_code = iata_code.upcase
    if airport = Airport.find_by(iata_code: iata_code)
      return airport
    else
      # Look up timezone and name on FlightXML
      airport_info = FlightXML::airport_info(iata_code)
      return nil unless airport_info
      
      new_airport = Airport.new(iata_code: iata_code, name: airport_info[:name], timezone: airport_info[:timezone], needs_review: true)
      if new_airport.save
        return new_airport
      else
        return nil
      end
      
    end
  end
  
  private
  
  def upcase_airport_codes
    self.iata_code = iata_code.upcase
    self.icao_code = icao_code.upcase
  end
  
end
