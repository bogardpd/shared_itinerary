class Flight < ActiveRecord::Base
  belongs_to :traveler
  belongs_to :airline
  belongs_to :origin_airport,      class_name: "Airport"
  belongs_to :destination_airport, class_name: "Airport"
  
  accepts_nested_attributes_for :airline
  
  validates :flight_number,          presence: true
  validates :origin_airport_id,      presence: true
  validates :destination_airport_id, presence: true
  validates :origin_time,            presence: true
  validates :destination_time,       presence: true
    
  before_validation :check_existing_airline
  
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
  
  def check_existing_airline
    if airline.new_record? && existing_airline = Airline.find_by(iata_code: airline.iata_code)
      self.airline = existing_airline
    end
  end
  
end
