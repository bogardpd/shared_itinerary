require 'test_helper'

class FlightsControllerTest < ActionController::TestCase
  
  def setup
    @flight = flights(:one)
    @different_flight = flights(:flight_with_different_user)
  end
  
  # NEW
  
  test "should redirect new when not logged in" do
    get :new, params: { traveler: travelers(:one) }
    assert_redirected_to login_url
  end
  
  test "should redirect new when wrong traveler" do
    log_in_as(users(:johndoe))
    get :new, params: { traveler: travelers(:two) }
    assert_redirected_to root_url
  end
  
  # CREATE
  
  test "should redirect create when not logged in" do
    assert_no_difference "Flight.count" do
      airline = airlines(:panam)
      orig_airport = airports(:atlanta)
      dest_airport = airports(:ohare)
      traveler = travelers(:one)
      post :create, params: { flight: { traveler_id: traveler.id, airline: airline, origin_airport: orig_airport, destination_airport: dest_airport, flight_number: 1234, origin_time: Time.now.utc, destination_time: (Time.now + 2.hours).utc} }
    end
    assert_redirected_to login_url
  end
  
  test "should redirect create when wrong traveler" do
    log_in_as(users(:johndoe))
    assert_no_difference "Flight.count" do
      airline = airlines(:panam)
      orig_airport = airports(:atlanta)
      dest_airport = airports(:ohare)
      traveler = travelers(:two)
      post :create, params: { flight: { traveler_id: traveler.id, airline: airline, origin_airport: orig_airport, destination_airport: dest_airport, flight_number: 1234, origin_time: Time.now.utc, destination_time: (Time.now + 2.hours).utc} }
    end
    assert_redirected_to root_url
  end
  
  # EDIT
  
  test "should redirect edit when not logged in" do
    get :edit, params: { id: @flight }
    assert_redirected_to login_url
  end
  
  test "should redirect edit when wrong user" do
    log_in_as(users(:johndoe))
    get :edit, params: { id: @different_flight }
    assert_redirected_to root_url
  end
  
  # UPDATE
  
  test "should redirect update when not logged in" do
    patch :update, params: { id: @flight, flight: { flight_number: 5678 } }
    assert_not flash.empty?
    assert_redirected_to login_url
  end
  
  test "should redirect update when wrong user" do
    log_in_as(users(:johndoe))
    patch :update, params: { id: @different_flight, flight: { flight_number: 5678 } }
    assert_redirected_to root_url
  end
  
  # DESTROY
  
  test "should redirect destroy when not logged in" do
    assert_no_difference "Flight.count" do
      delete :destroy, params: { id: @flight }
    end
    assert_redirected_to login_url
  end
  
  test "should redirect destroy when wrong user" do
    log_in_as(users(:johndoe))
    assert_no_difference "Flight.count" do
      delete :destroy, params: { id: @different_flight }
    end
    assert_redirected_to root_url
  end
  
end
