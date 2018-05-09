class Flight < ActiveRecord::Base
  belongs_to :traveler
  belongs_to :airline
  belongs_to :origin_airport,      class_name: "Airport"
  belongs_to :destination_airport, class_name: "Airport"
  
  validates :flight_number,          presence: true
  validates :airline_id,             presence: true
  validates :origin_airport_id,      presence: true
  validates :destination_airport_id, presence: true
  validates :origin_time,            presence: true
  validates :destination_time,       presence: true
  
  before_save { self.origin_time = Time.parse(origin_time.to_s) }
  before_save { self.destination_time = Time.parse(destination_time.to_s)}
  
  scope :chronological, -> {
    order("flights.origin_time")
  }  

  attr_accessor :airline_iata_code
  
  def departure_is_before_arrival
    errors[:base] << "The flight's departure must come before its arrival" unless self.origin_time && self.destination_time && self.origin_time < self.destination_time
  end
  
  def airline_iata
    self.airline ? self.airline.iata_code : ""
  end
  
  def airline_name
    self.airline ? self.airline.formatted_name : ""
  end
  
  def dep_airport_iata
    self.origin_airport ? self.origin_airport.iata_code : ""
  end
  
  def dep_airport_name
    self.origin_airport ? self.origin_airport.formatted_name : ""
  end
  
  def dep_airport_city
    self.origin_airport ? self.origin_airport.name : ""
  end
  
  def arr_airport_iata
    self.destination_airport ? self.destination_airport.iata_code : ""
  end
  
  def arr_airport_name
    self.destination_airport ? self.destination_airport.formatted_name : ""
  end
  
  def arr_airport_city
    self.destination_airport ? self.destination_airport.name : ""
  end
  
end
