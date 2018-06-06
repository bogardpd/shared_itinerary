require 'test_helper'

class AirlineTest < ActiveSupport::TestCase
  
  def setup
    @airline = Airline.new(iata_code: "AA", icao_code: "AAL", name: "American")
  end
  
  test "should be valid" do
    assert @airline.valid?
  end
  
  test "iata_code should not be too long" do
    @airline.iata_code = "AAA"
    assert_not @airline.valid?
  end
  
  test "icao_code should not be too long" do
    @airline.icao_code = "AAAA"
    assert_not @airline.valid?
  end
  
end
