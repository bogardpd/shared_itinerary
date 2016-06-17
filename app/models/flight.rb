class Flight < ActiveRecord::Base
  belongs_to :section
  validates :airline_iata, presence: true
  validates :flight_number, presence: true
  validates :departure_airport_iata, presence: true
  validates :arrival_airport_iata, presence: true
  validates :departure_datetime, presence: true
  validates :arrival_datetime, presence: true
  before_save { self.airline_iata = airline_iata.upcase }
  before_save { self.departure_airport_iata = departure_airport_iata.upcase }
  before_save { self.arrival_airport_iata = arrival_airport_iata.upcase }
  
  
end
