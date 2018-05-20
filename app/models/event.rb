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
  
  def flight_data
    event_timezone = TZInfo::Timezone.get(self.timezone || "UTC")
    event_travelers = self.travelers.includes(:flights)
    event_flights = Flight.where(traveler_id: self.travelers).includes(:airline, :origin_airport, :destination_airport, :traveler)
    
    data = {arrivals: Hash.new, departures: Hash.new}
    
    traveler_flights = Hash.new
    event_flights.each do |flight|
      unless traveler_flights.key?(flight.traveler_id)
        traveler_flights[flight.traveler_id] = {arrivals: {flights: Array.new}, departures: {flights: Array.new}}
      end
      flight_arr_dep = flight.is_event_arrival ? :arrivals : :departures
      traveler_flights[flight.traveler_id][flight_arr_dep][:flights].push({
        origin_iata: flight.origin_airport.iata_code,
        origin_time_utc: flight.origin_time,
        destination_iata: flight.destination_airport.iata_code,
        destination_time_utc: flight.destination_time
      }) 
    end
    
    # Calculate key times and airports:
    traveler_flights.each do |traveler, directions|
      if directions[:arrivals][:flights].any?
        directions[:arrivals][:flights].sort_by!{|f| f[:destination_time_utc]}
        directions[:arrivals][:key_iata] = directions[:arrivals][:flights].last[:destination_iata]
        directions[:arrivals][:key_time_utc] = directions[:arrivals][:flights].last[:destination_time_utc]
        directions[:arrivals][:alt_time_utc] = directions[:arrivals][:flights].first[:origin_time_utc]
      end
      if directions[:departures][:flights].any?
        directions[:departures][:flights].sort_by!{|f| f[:origin_time_utc]}
        directions[:departures][:key_iata] = directions[:departures][:flights].first[:origin_iata]
        directions[:departures][:key_time_utc] = directions[:departures][:flights].first[:origin_time_utc]
        directions[:departures][:alt_time_utc] = directions[:departures][:flights].last[:destination_time_utc]
      end
    end
    
    # Build data hash:
    event_flights.each do |flight|
      flight_details = {
        airline_iata: flight.airline.iata_code,
        airline_name: flight.airline.name,
        flight_number: flight.flight_number,
        origin_iata: flight.origin_airport.iata_code,
        origin_name: flight.origin_airport.name,
        origin_time_utc: flight.origin_time,
        destination_iata: flight.destination_airport.iata_code,
        destination_name: flight.destination_airport.name,
        destination_time_utc: flight.destination_time
      }
      
      arr_dep = flight.is_event_arrival ? :arrivals : :departures
      local_dates = (flight.origin_time.in_time_zone(event_timezone).to_date .. flight.destination_time.in_time_zone(event_timezone).to_date).to_a
      local_dates.each do |local_date|
        unless data[arr_dep].key?(local_date)
          start_time_utc = Time.find_zone(event_timezone).local(local_date.year, local_date.month, local_date.day).utc
          end_time_utc = Time.find_zone(event_timezone).local(local_date.year, local_date.month, local_date.day, 24).utc
          data[arr_dep].store(local_date, {
            start_time_utc: start_time_utc,
            end_time_utc:   end_time_utc,
            travelers: Hash.new
          })
        end
        unless data[arr_dep][local_date][:travelers].key?(flight.traveler_id)
          # Determine key_iata, key_time_utc, alt_time_utc
          
          if flight.is_event_arrival
            key_iata     = traveler_flights[flight.traveler_id][:arrivals][:key_iata]
            key_time_utc = traveler_flights[flight.traveler_id][:arrivals][:key_time_utc]
            alt_time_utc = traveler_flights[flight.traveler_id][:arrivals][:alt_time_utc]
          else
            key_iata     = traveler_flights[flight.traveler_id][:departures][:key_iata]
            key_time_utc = traveler_flights[flight.traveler_id][:departures][:key_time_utc]
            alt_time_utc = traveler_flights[flight.traveler_id][:departures][:alt_time_utc]
          end
          
          data[arr_dep][local_date][:travelers].store(flight.traveler_id, {
            name: flight.traveler.traveler_name,
            note: flight.traveler.traveler_note,
            key_iata: key_iata,
            key_time_utc: key_time_utc,
            alt_time_utc: alt_time_utc,
            arrival_departure_info: flight.is_event_arrival ? flight.traveler.arrival_info : flight.traveler.departure_info,
            flights: Array.new()
          })
        end
        data[arr_dep][local_date][:travelers][flight.traveler_id][:flights].push(flight_details)
      end
    end
    
    # TODO: sort arrivals by traveler key destination time, and departures by traveler key origin time
    
    return data
    
    
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
  
  private
  
  # Returns a date range (in the event timezone) that includes the entire
  # duration of all flights
  # def date_range_local(flights, timezone)
  #   return (flights.pluck(:origin_time).min.in_time_zone(timezone).to_date ..  flights.pluck(:destination_time).max.in_time_zone(timezone).to_date).to_a
  # end
  
end