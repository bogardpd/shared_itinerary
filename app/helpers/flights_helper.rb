module FlightsHelper
  
  def setup_flight(flight)
    flight.airline ||= Airline.new
    flight.origin_airport ||= Airport.new
    flight.destination_airport ||= Airport.new
    return flight
  end
  
  def time_field_value_in_local(time, airport)
    return nil unless (time && airport && airport.timezone)
    timezone = TZInfo::Timezone.get(airport.timezone)
    return time.in_time_zone(timezone).strftime("%Y-%m-%d %H:%M")
    
  rescue TZInfo::InvalidTimezoneIdentifier
    return nil
  end

  # Determines whether arrival or departure should be preselected based on
  # object values an parameter inputs. Returns true if arrival, false if departure.
  def is_arrival(f)
    if f.new_record?
      if params[:direction]
        return (params[:direction] != "departure")
      else
        return true
      end
    else
      return f.is_event_arrival
    end
  end
  
end