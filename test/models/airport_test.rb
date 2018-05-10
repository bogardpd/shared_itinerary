require 'test_helper'

class AirportTest < ActiveSupport::TestCase
  
  def setup
    @airport = Airport.new(iata_code: "LAX", name: "Los Angeles", timezone: "America/Los_Angeles")
  end
  
  test "should be valid" do
    assert @airport.valid?
  end
  
  test "iata_code should be present" do
    @airport.iata_code = nil
    assert_not @airport.valid?
  end
  
  test "iata_code should not be too long" do
    @airport.iata_code = "AAAA"
    assert_not @airport.valid?
  end
  
  test "timezone should be present" do
    @airport.timezone = nil
    assert_not @airport.valid?
  end
  
end
