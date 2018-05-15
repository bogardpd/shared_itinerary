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
  
  # TEMPORARY method to convert flight origin and destination times from event local to UTC
  def convert_to_utc
    return nil if self.timezone.blank?
    tz = TZInfo::Timezone.get(self.timezone)
    puts "Event timezone: #{tz}"
    flights = Flight.where(traveler_id: self.travelers).includes(:airline, :origin_airport, :destination_airport)
  
    flights.each do |flight|
      puts "----------------------------------------"
      puts "#{flight.origin_airport.iata_code}—#{flight.destination_airport.iata_code} #{flight.airline.iata_code} #{flight.flight_number}"
      puts "#{self.timezone}:\n  #{flight.origin_time.strftime("%F %R")}        ... #{flight.destination_time.strftime("%F %R")}"
      origin_utc = tz.local_to_utc(flight.origin_time)
      destination_utc = tz.local_to_utc(flight.destination_time)
      puts "UTC:\n  #{origin_utc} ... #{destination_utc}"
      puts "\n"
      
      flight.origin_time = origin_utc
      flight.destination_time = destination_utc
      flight.save
    end
    
    return nil
  end
  
end