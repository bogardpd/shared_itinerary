require 'test_helper'

class EventsControllerTest < ActionController::TestCase
  
  def setup
    @event = events(:one)
  end
  
  test "should redirect create when not logged in" do
    assert_no_difference 'Event.count' do
      post :create, event: { event_name: "Convention", arriving_timezone: "EST", departing_timezone: "EST" }
    end
    assert_redirected_to login_url
  end
  
  # Write test for redirect update when not logged in
  
  test "should redirect destroy when not logged in" do
    assert_no_difference 'Event.count' do
      delete :destroy, id: @event
    end
    assert_redirected_to login_url
  end
  
  # Write test for redirect update for wrong event
  
  test "should redirect destroy for wrong event" do
    log_in_as(users(:johndoe))
    event = events(:different_owner)
    assert_no_difference 'Event.count' do
      delete :destroy, id: event
    end
    assert_redirected_to root_url
  end
end
