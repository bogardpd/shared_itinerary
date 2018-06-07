class Flight < ActiveRecord::Base  
  belongs_to :traveler
  belongs_to :airline
  belongs_to :origin_airport,      class_name: "Airport"
  belongs_to :destination_airport, class_name: "Airport"
  
  accepts_nested_attributes_for :airline
  accepts_nested_attributes_for :origin_airport
  accepts_nested_attributes_for :destination_airport
  
  validates :flight_number,          presence: true
  validates :origin_time,            presence: true
  validates :destination_time,       presence: true
    
  before_validation :check_existing_airline_and_airports
  before_validation :convert_local_times_to_utc
  
  before_save { self.origin_time = Time.parse(origin_time.to_s) }
  before_save { self.destination_time = Time.parse(destination_time.to_s)}
  
  scope :chronological, -> {
    order("flights.origin_time")
  }  
  
  def departure_is_before_arrival
    errors[:base] << "The flight's departure must come before its arrival" unless self.origin_time && self.destination_time && self.origin_time < self.destination_time
  end
  
  def airline_iata
    self.airline ? self.airline.iata_code : ""
  end
  
  def airline_name
    self.airline ? self.airline.formatted_name : ""
  end
  
  def origin_airport_iata
    self.origin_airport ? self.origin_airport.iata_code : ""
  end
  
  def origin_airport_name
    self.origin_airport ? self.origin_airport.formatted_name : ""
  end
  
  def origin_airport_city
    self.origin_airport ? self.origin_airport.name : ""
  end
  
  # Returns the origin departure time in the origin airport's local timezone.
  # The check for origin_time is necessary in the case of a form where a user left
  # the field blank; we'll thus have an unsaved Flight without a origin_time.
  def origin_time_local
    return self.origin_time ?  Time.at(self.origin_time).in_time_zone(TZInfo::Timezone.get(self.origin_airport.timezone)) : ""
  end
  
  def destination_airport_iata
    self.destination_airport ? self.destination_airport.iata_code : ""
  end
  
  def destination_airport_name
    self.destination_airport ? self.destination_airport.formatted_name : ""
  end
  
  def destination_airport_city
    self.destination_airport ? self.destination_airport.name : ""
  end
  
  # Returns the destination arrival time in the destination airport's local
  # timezone. The check for destination_time is necessary in the case of a form
  # where a user left the field blank; we'll thus have an unsaved Flight
  # without a origin_time.
  def destination_time_local
    return self.destination_time ?  Time.at(self.destination_time).in_time_zone(TZInfo::Timezone.get(self.destination_airport.timezone)) : ""
  end
  
  private
  
  def check_existing_airline_and_airports
    # Airline:
    airline_iata = self.airline.iata_code&.upcase
    if (existing_airline = Airline.find_by(iata_code: airline_iata))
      self.airline = existing_airline
    else
      self.airline = Airline.new(iata_code: airline_iata)
    end
    
    # Origin airport:
    origin_iata = self.origin_airport.iata_code&.upcase
    if (existing_origin = Airport.find_by(iata_code: origin_iata))
      self.origin_airport = existing_origin
    else
      if (orig_info = FlightXML::airport_info(origin_iata))
        self.origin_airport = Airport.new(iata_code: origin_iata, name: orig_info[:name], timezone: orig_info[:timezone], needs_review: true)
      else
        self.origin_airport = Airport.new(iata_code: origin_iata)
      end
    end
          
    # Destination airport:
    destination_iata = self.destination_airport.iata_code&.upcase
    if (existing_destination = Airport.find_by(iata_code: destination_iata))
      self.destination_airport = existing_destination
    else
      if (dest_info = FlightXML::airport_info(destination_iata))
        self.destination_airport = Airport.new(iata_code: destination_iata, name: dest_info[:name], timezone: dest_info[:timezone], needs_review: true)
      else
        self.destination_airport = Airport.new(iata_code: destination_iata)
      end
    end
    
  end
  
  def convert_local_times_to_utc
    if self.origin_airport.timezone
      origin_timezone = TZInfo::Timezone.get(self.origin_airport.timezone)
      self.origin_time = convert_local_time_to_utc(self.origin_time, origin_timezone)
    end    
    if self.destination_airport.timezone
      destination_timezone = TZInfo::Timezone.get(self.destination_airport.timezone)
      self.destination_time = convert_local_time_to_utc(self.destination_time, destination_timezone)
    end    
  end
  
  def convert_local_time_to_utc(local_time, timezone)
    timezone.local_to_utc(local_time, dst=false)
  rescue ArgumentError
    return nil
  end
  
end
