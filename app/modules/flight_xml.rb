# Used to interact with FlightAware's FlightXML API.

module FlightXML
  
  # Defines the Savon client to connect to the FlightXML API.
  def self.client
    return Savon.client(wsdl: "https://flightxml.flightaware.com/soap/FlightXML2/wsdl", basic_auth: [ENV["FLIGHTAWARE_USERNAME"], ENV["FLIGHTAWARE_API_KEY"]])
  end
  
  # Accepts an airport IATA or ICAO code, and returns a FlightXML hash of info
  # about the airport.
  def self.airport_info(airport_code)
    begin
      info = client.call(:airport_info, message: {
        airport_code: airport_code
        }).to_hash[:airport_info_results][:airport_info_result]
      return info
    rescue
      return nil
    end
  end
  
end