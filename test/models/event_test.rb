require 'test_helper'

class EventTest < ActiveSupport::TestCase

  def setup
    @user = users(:johndoe)
    @event = @user.events.build(event_name: "Convention", arriving_timezone: "EST", departing_timezone: "EST")
  end
  
  test "should be valid" do
    assert @event.valid?
  end
  
  test "user id should be present" do
    @event.user_id = nil
    assert_not @event.valid?
  end
  
  test "event name should be present" do
    @event.event_name = "   "
    assert_not @event.valid?
  end
  
  test "arriving timezone should be present" do
    @event.arriving_timezone = "   "
    assert_not @event.valid?
  end
  
  test "departing timezone should be present" do
    @event.departing_timezone = "   "
    assert_not @event.valid?
  end
  
  test "associated travelers should be destroyed" do
    @event.save
    @event.travelers.create!(traveler_name: "Bob", traveler_note: "bibbity_bob", arrival_info: "rental car", departure_info: "zeppelin")
    assert_difference 'Traveler.count', -1 do
      @event.destroy
    end
  end
  
end
