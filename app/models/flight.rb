class Flight < ActiveRecord::Base
  belongs_to :traveler
  belongs_to :airline
  belongs_to :departure_airport, :class_name => 'Airport'
  belongs_to :arrival_airport,   :class_name => 'Airport'
  
  validates :flight_number,        presence: true
  validates :airline_id,           presence: true
  validates :departure_airport_id, presence: true
  validates :arrival_airport_id,   presence: true
  validates :departure_datetime,   presence: true
  validates :arrival_datetime,     presence: true
  
  before_save { self.departure_datetime = Time.parse(departure_datetime.to_s) }
  before_save { self.arrival_datetime = Time.parse(arrival_datetime.to_s)}

  attr_accessor :airline_iata_code
  
  def departure_is_before_arrival
    errors[:base] << "The flight's departure must come before its arrival" unless self.departure_datetime && self.arrival_datetime && self.departure_datetime < self.arrival_datetime
  end
  
  def airline_iata
    self.airline ? self.airline.iata_code : ""
  end
  
  def airline_name
    self.airline ? self.airline.formatted_name : ""
  end
  
  def dep_airport_iata
    self.departure_airport ? self.departure_airport.iata_code : ""
  end
  
  def dep_airport_name
    self.departure_airport ? self.departure_airport.formatted_name : ""
  end
  
  def arr_airport_iata
    self.arrival_airport ? self.arrival_airport.iata_code : ""
  end
  
  def arr_airport_name
    self.arrival_airport ? self.arrival_airport.formatted_name : ""
  end
  
end
