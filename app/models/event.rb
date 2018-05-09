class Event < ActiveRecord::Base
  belongs_to :user
  has_many   :travelers, dependent: :destroy
  
  validates :user_id, presence: true
  validates :event_name, presence: true
  
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
    
    travelers.eager_load(flights: [:origin_airport, :destination_airport]).each do |traveler|
      flight_list = traveler.flights.order(:origin_time)
      arrival_flights   = flight_list.where(is_event_arrival: true)
      departure_flights = flight_list.where(is_event_arrival: false)
      
      arrivals.push(   traveler:    traveler,
                       flights:     arrival_flights,
                       key_airport: arrival_flights.any? ? arrival_flights.last.destination_airport : Airport.new,
                       key_iata:    arrival_flights.any? ? arrival_flights.last.destination_airport.iata_code : "",
                       key_time:    arrival_flights.any? ? arrival_flights.last.destination_time : nil,
                       alt_time:    arrival_flights.any? ? arrival_flights.first.origin_time : nil,
                       pickup_info: traveler.arrival_info)

      departures.push( traveler:    traveler,
                       flights:     departure_flights,
                       key_airport: departure_flights.any? ? departure_flights.first.origin_airport : Airport.new,
                       key_iata:    departure_flights.any? ? departure_flights.first.origin_airport.iata_code : "",
                       key_time:    departure_flights.any? ? departure_flights.first.origin_time : nil,
                       alt_time:    departure_flights.any? ? departure_flights.last.destination_time : nil,
                       pickup_info: traveler.departure_info)
                       
    end
    
    arrivals.sort_by!   { |h| [h[:key_iata], h[:key_time], h[:alt_time]] }
    departures.sort_by! { |h| [h[:key_iata], h[:key_time], h[:alt_time]] }
    traveler_hash[:arrivals]   = arrivals
    traveler_hash[:departures] = departures
    
    return traveler_hash
  end
  
end