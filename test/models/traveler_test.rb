require 'test_helper'

class TravelerTest < ActiveSupport::TestCase

  def setup
    @event = events(:one)
    @section = @event.travelers.build(traveler_name: "Bob", traveler_note: "bibbity_bob", arrival_info: "rental car", departure_info: "zeppelin", is_arrival: true)
  end
  
  test "should be valid" do
    assert @section.valid?
  end
  
  test "event id should be present" do
    @section.event_id = nil
    assert_not @section.valid?
  end
  
  test "traveler name should be present" do
    @section.traveler_name = "   "
    assert_not @section.valid?
  end
  
end
