module FlightsHelper
  
  def setup_flight(flight)
    flight.airline ||= Airline.new
    return flight
  end
  
end