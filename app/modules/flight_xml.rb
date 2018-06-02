# Used to interact with FlightAware's FlightXML API.

module FlightXML
  
  # Defines the Savon client to connect to the FlightXML API.
  def self.client
    return Savon.client(wsdl: "https://flightxml.flightaware.com/soap/FlightXML2/wsdl", basic_auth: [ENV["FLIGHTAWARE_USERNAME"], ENV["FLIGHTAWARE_API_KEY"]])
  end
  
  # Accepts an airport IATA or ICAO code, and returns a hash of info about the
  # airport from FlightXML.
  def self.airport_info(airport_code)
    begin
      info = client.call(:airport_info, message: {
        airport_code: airport_code
        }).to_hash[:airport_info_results][:airport_info_result]
      return {name: info[:name], timezone: info[:timezone].tr(":","")}
    rescue
      return nil
    end
  end
  
  # Accepts an airport IATA or ICAO code, and returns the airport IANA timezone
  # string.
  def self.airport_timezone(airport_code)
    begin
      timezone = client.call(:airport_info, message: {
        airport_code: airport_code
      }).to_hash[:airport_info_results][:airport_info_result][:timezone].tr(":","")
      return timezone
    rescue
      return nil
    end
  end
  
  # Accepts an airline IATA or ICAO code, a flight number, and a local departure
  # date. Returns an array of FlightXML flight data which match.
  def self.matching_flights(airline_code, flight_number, departure_date_local)
    return [] unless airline_code && flight_number && departure_date_local
    departure_date_array = [departure_date_local.year, departure_date_local.month, departure_date_local.day]
    departure_utc_range = (Time.new(*departure_date_array, 0, 0, 0, "+14:00").utc)..(Time.new(*departure_date_array, 24, 0, 0, "-12:00").utc) # Calculate the largest possible time range for the departure date in all timezones
    
    begin
      flights = client.call(:airline_flight_schedules, message: {
        start_date: departure_utc_range.begin.to_i,
        end_date:   departure_utc_range.end.to_i,
        airline:    airline_code,
        flightno:   flight_number.to_s
        }).to_hash[:airline_flight_schedules_results][:airline_flight_schedules_result][:data]
        return [] if flights.nil?
    rescue
      return []
    end
    
    # Get timezones of origin airports:
    origin_airports = flights.map{|f| f[:origin]}.uniq
    origin_airport_timezones = Hash.new
    origin_airports.each do |airport_code|
      return [] unless origin_airport_timezones[airport_code] = airport_timezone(airport_code)
    end
    
    # Create results hash:
    flights = flights.map{|f| {airline: f[:ident][0..2], flight_number: f[:ident][3..-1], origin_airport_icao: f[:origin], destination_airport_icao: f[:destination], origin_time_utc: Time.at(f[:departuretime].to_i).utc, destination_time_utc: Time.at(f[:arrivaltime].to_i).utc, origin_date_local: Time.at(f[:departuretime].to_i).in_time_zone(origin_airport_timezones[f[:origin]]).to_date }}.sort_by{|f| f[:origin_time_utc]}
    
    # Filter flights by local date:
    flights = flights.select{|f| f[:origin_date_local] == departure_date_local}
    
    return flights
  end
  
end