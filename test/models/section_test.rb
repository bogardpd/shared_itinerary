require 'test_helper'

class SectionTest < ActiveSupport::TestCase

  def setup
    @event = events(:one)
    @section = @event.sections.build(traveler_name: "Bob", traveler_note: "bibbity_bob", pickup_info: "rental car", is_arrival: true)
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
