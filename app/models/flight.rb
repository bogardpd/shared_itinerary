class Flight < ActiveRecord::Base
  belongs_to :section
  belongs_to :airline
  validates :airline_iata, presence: true
  validates :flight_number, presence: true
  validates :departure_airport_iata, presence: true
  validates :arrival_airport_iata, presence: true
  validates :departure_datetime, presence: true
  validates :arrival_datetime, presence: true
  
  validate :departure_is_before_arrival
  
  before_save { self.airline_iata = airline_iata.upcase }
  before_save { self.departure_airport_iata = departure_airport_iata.upcase }
  before_save { self.arrival_airport_iata = arrival_airport_iata.upcase }
  before_save { self.departure_datetime = Time.parse(departure_datetime.to_s) }
  before_save { self.arrival_datetime = Time.parse(arrival_datetime.to_s)}
  
  def departure_is_before_arrival
    errors[:base] << "The flight's departure must come before its arrival" unless self.departure_datetime && self.arrival_datetime && self.departure_datetime < self.arrival_datetime
  end
  
  def airline_iata
    self.airline ? self.airline.iata_code : ""
  end
  
  def airline_name
    self.airline ? self.airline.formatted_name : ""
  end 
  
end
