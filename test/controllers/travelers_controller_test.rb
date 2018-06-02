require "test_helper"

class TravelersControllerTest < ActionController::TestCase
  def setup
    @event = events(:one)
  end
  
  test "should redirect create when not logged in" do
    assert_no_difference "Traveler.count" do
      post :create, params: { section: { traveler_name: "John Doe", traveler_note: "jdoe", pickup_info: "Rental Car", is_arrival: true}, event: @event }
    end
    assert_redirected_to login_url
  end
  
  test "should redirect new flight search for wrong traveler" do
    log_in_as(users(:johndoe))
    traveler = travelers(:two)
    get :new_flight_search, params: { id: traveler }
    assert_redirected_to root_url
  end
  
  test "should redirect create for wrong traveler" do
    log_in_as(users(:johndoe))
    event = events(:different_owner)
    assert_no_difference "Traveler.count" do
      post :create, params: { section: { traveler_name: "Bob Smith", traveler_note: "bsmith", pickup_info: "Rental Car", is_arrival: true}, event: event }
    end
    assert_redirected_to root_url
  end
  
  test "should redirect destroy for wrong traveler" do
    log_in_as(users(:johndoe))
    traveler = travelers(:two)
    assert_no_difference "Traveler.count" do
      delete :destroy, params: { id: traveler }
    end
    assert_redirected_to root_url
  end
  
end


