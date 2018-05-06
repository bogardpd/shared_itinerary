class Event < ActiveRecord::Base
  belongs_to :user
  has_many   :travelers, dependent: :destroy
  
  validates :user_id, presence: true
  validates :event_name, presence: true
  validates :arriving_timezone, presence: true
  validates :departing_timezone, presence: true
  
  # Return this event's Chart object.
  def chart
    return Chart.new(self)
  end
  
  # Return a hash of departures and arrivals, with :arrivals or :departures as
  # the keys and arrays of travelers as the values.
  def event_travelers
    traveler_hash = Hash.new
    arrivals   = Array.new
    departures = Array.new
    
    travelers.eager_load(flights: [:arrival_airport, :departure_airport]).each do |traveler|
      flight_list = traveler.flights.order(:departure_datetime)
      arrival_flights   = flight_list.where(is_arrival: true)
      departure_flights = flight_list.where(is_arrival: false)
      
      arrivals.push(   traveler:    traveler,
                       flights:     arrival_flights,
                       key_airport: arrival_flights.any? ? arrival_flights.last.arrival_airport : Airport.new,
                       key_iata:    arrival_flights.any? ? arrival_flights.last.arrival_airport.iata_code : "",
                       key_time:    arrival_flights.any? ? arrival_flights.last.arrival_datetime : nil,
                       alt_time:    arrival_flights.any? ? arrival_flights.first.departure_datetime : nil,
                       pickup_info: traveler.arrival_info)

      departures.push( traveler:    traveler,
                       flights:     departure_flights,
                       key_airport: departure_flights.any? ? departure_flights.first.departure_airport : Airport.new,
                       key_iata:    departure_flights.any? ? departure_flights.first.departure_airport.iata_code : "",
                       key_time:    departure_flights.any? ? departure_flights.first.departure_datetime : nil,
                       alt_time:    departure_flights.any? ? departure_flights.last.arrival_datetime : nil,
                       pickup_info: traveler.departure_info)
                       
    end
    
    arrivals.sort_by!   { |h| [h[:key_iata], h[:key_time], h[:alt_time]] }
    departures.sort_by! { |h| [h[:key_iata], h[:key_time], h[:alt_time]] }
    traveler_hash[:arrivals]   = arrivals
    traveler_hash[:departures] = departures
    
    return traveler_hash
  end
  
end