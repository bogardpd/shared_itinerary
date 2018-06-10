class Event < ActiveRecord::Base
  belongs_to :user
  has_many   :travelers, dependent: :destroy
  
  validates :user_id, presence: true
  validates :event_name, presence: true
  
  # Return this event's Chart object.
  def chart
    return Chart.new(self)
  end
  
  # Return this event's timezone, or UTC if not set.
  def event_timezone
    return TZInfo::Timezone.get(self.timezone) if self.timezone.present?
    return TZInfo::Timezone.get("UTC")      
  end
  
  # Returns the range of dates this event's travel covers, in the event's
  # timezone
  def travel_date_range
    flights = Flight.select(:origin_time, :destination_time).where(traveler_id: self.travelers)
    return nil unless flights.any?
    min_orig_time = flights.map{|f| f[:origin_time] }.min.in_time_zone(event_timezone).to_date
    max_dest_time = flights.map{|f| f[:destination_time] }.max.in_time_zone(event_timezone).to_date
    return min_orig_time..max_dest_time
  end
  
  # Returns a hash of key airports and hues for each airport
  def airport_hues
    data = flight_data_by_traveler
    return nil unless data
    hues = Hash.new
    key_airports = Set.new
    data.each do |traveler_id, traveler|
      [:arrivals, :departures].each do |direction|
        key_airports.add(traveler[direction][:key_code])
      end
    end
    
    key_airports.reject!(&:blank?)
    hue_step = key_airports.length > 0 ? 360/key_airports.length : 0
    key_airports.to_a.sort.each_with_index do |airport, index|
      hues[airport] = index*hue_step
    end
    
    return hues
    
  end
  
  # Returns a summary of flight and layover data for each traveler
  def flight_data_by_traveler
    event_flights = Flight.where(traveler_id: self.travelers).includes(:airline, :origin_airport, :destination_airport, :traveler)
    traveler_flights = Hash.new
    
    self.travelers.each do |traveler|
    traveler_flights[traveler.id] = {
      traveler_name: traveler.traveler_name,
      traveler_note: traveler.traveler_note,
      arrivals: {flights: Array.new, layovers: Array.new, info: traveler.arrival_info},
      departures: {flights: Array.new, layovers: Array.new, info: traveler.departure_info}
    }
    end
        
    event_flights.each do |flight|
      flight_arr_dep = flight.is_event_arrival ? :arrivals : :departures
      traveler_flights[flight.traveler_id][flight_arr_dep][:flights].push({
        id: flight.id,
        airline_code: flight.airline.code,
        airline_icao: flight.airline.icao_code,
        airline_name: flight.airline.name,
        flight_number: flight.flight_number,
        origin_code: flight.origin_airport.code,
        origin_name: flight.origin_airport.name,
        origin_time_utc: flight.origin_time,
        origin_time_local: flight.origin_time.in_time_zone(flight.origin_airport.timezone),
        destination_code: flight.destination_airport.code,
        destination_name: flight.destination_airport.name,
        destination_time_utc: flight.destination_time,
        destination_time_local: flight.destination_time.in_time_zone(flight.destination_airport.timezone)
      }) 
    end
    
    # Calculate key times and airports:
    traveler_flights.each do |traveler, directions|
      if directions[:arrivals][:flights].any?
        directions[:arrivals][:flights].sort_by!{|f| f[:destination_time_utc]}
        directions[:arrivals][:key_code] = directions[:arrivals][:flights].last[:destination_code]
        directions[:arrivals][:key_time_utc] = directions[:arrivals][:flights].last[:destination_time_utc]
        directions[:arrivals][:alt_time_utc] = directions[:arrivals][:flights].first[:origin_time_utc]
        directions[:arrivals][:layovers] = layovers(directions[:arrivals][:flights])
      end
      if directions[:departures][:flights].any?
        directions[:departures][:flights].sort_by!{|f| f[:origin_time_utc]}
        directions[:departures][:key_code] = directions[:departures][:flights].first[:origin_code]
        directions[:departures][:key_time_utc] = directions[:departures][:flights].first[:origin_time_utc]
        directions[:departures][:alt_time_utc] = directions[:departures][:flights].last[:destination_time_utc]
        directions[:departures][:layovers] = layovers(directions[:departures][:flights])
      end
    end
    
    return traveler_flights
    
  end
  
  # Summarizes flight data by date and traveler.
  def flight_data_by_date
    
    by_traveler = flight_data_by_traveler
    return nil unless by_traveler
    
    # Build data hash:
    data = {arrivals: Hash.new, departures: Hash.new}
    by_traveler.each do |traveler_id, traveler|
      [:arrivals, :departures].each do |direction|
        
        # Add flights and layovers:
        
        [:flights, :layovers].each do |type|
          traveler[direction][type].each do |period|
            start_time_utc = period[:origin_time_utc]      || period[:start_time_utc]
            end_time_utc   = period[:destination_time_utc] || period[:end_time_utc]
            local_dates(start_time_utc, end_time_utc).each do |local_date|
            
              # Create date hash if needed:
              unless data[direction].key?(local_date)
                data[direction].store(local_date, date_details(local_date))
              end
            
              # Create traveler hash if needed:
              unless data[direction][local_date][:travelers].key?(traveler_id)
              
                # Determine key_code, key_time_utc, alt_time_utc
                if direction == :arrivals
                  key_code     = by_traveler[traveler_id][:arrivals][:key_code]
                  key_time_utc = by_traveler[traveler_id][:arrivals][:key_time_utc]
                  alt_time_utc = by_traveler[traveler_id][:arrivals][:alt_time_utc]
                else
                  key_code     = by_traveler[traveler_id][:departures][:key_code]
                  key_time_utc = by_traveler[traveler_id][:departures][:key_time_utc]
                  alt_time_utc = by_traveler[traveler_id][:departures][:alt_time_utc]
                end
          
                data[direction][local_date][:travelers].store(traveler_id, {
                  name: traveler[:traveler_name],
                  note: traveler[:traveler_note],
                  key_code: key_code,
                  key_time_utc: key_time_utc,
                  alt_time_utc: alt_time_utc,
                  arrival_departure_info: traveler[direction][:info],
                  flights: Array.new,
                  layovers: Array.new
                })
              end
            
              # Push flight to array
              data[direction][local_date][:travelers][traveler_id][type].push(period)
            
            end
            
          end
          # Sort each direction by date:
          data[direction] = data[direction].sort.to_h
        end
        
      end
    end
    
    # Sort each direction/date by key_code, key_time_utc, alt_time_utc:
    [:arrivals, :departures].each do |direction|
      data[direction].each do |local_date, local_date_data|
        data[direction][local_date][:travelers] = data[direction][local_date][:travelers].sort_by{|k,v| [v[:key_code], v[:key_time_utc], v[:alt_time_utc]]}.to_h
      end
    end
    
    return data
    
  end
  
  private
  
  def date_details(local_date)
    start_time_utc = Time.find_zone(event_timezone).local(local_date.year, local_date.month, local_date.day).utc
    end_time_utc   = Time.find_zone(event_timezone).local(local_date.year, local_date.month, local_date.day, 24).utc
    return {
      start_time_utc: start_time_utc,
      end_time_utc:   end_time_utc,
      travelers: Hash.new
    }
  end
  
  
  # Accepts an array of flight hashes, and returns an array of layover hashes
  def layovers(flights)
    return Array.new unless flights.length > 1
    layovers_result = Array.new
    (1..flights.length-1).each do |flight_index|
      if flights[flight_index-1][:destination_time_utc] < flights[flight_index][:origin_time_utc]
        layovers_result.push({
          start_code:     flights[flight_index-1][:destination_code],
          start_name:     flights[flight_index-1][:destination_name],
          start_time_utc: flights[flight_index-1][:destination_time_utc],
          end_code:       flights[flight_index][:origin_code],
          end_name:       flights[flight_index][:origin_name],
          end_time_utc:   flights[flight_index][:origin_time_utc]
        })
      end
    end
    
    return layovers_result
  
  end
  
  # Returns a date range (in the event timezone) that includes the entire
  # duration of all flights or layovers
  def local_dates(begin_time_utc, end_time_utc)
    return (begin_time_utc.in_time_zone(event_timezone).to_date .. end_time_utc.in_time_zone(event_timezone).to_date).to_a
  end
  
end