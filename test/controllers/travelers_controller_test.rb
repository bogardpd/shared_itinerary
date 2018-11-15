require "test_helper"

class TravelersControllerTest < ActionController::TestCase
  def setup
    @event = events(:one)
  end

  # NEW

  test "should get new for correct user" do
    log_in_as users(:johndoe)
    get :new, params: { event: @event }
    assert_response :success
  end

  test "should redirect new for incorrect user" do
    log_in_as users(:archer)
    get :new, params: { event: @event }
    assert_redirected_to root_url
  end

  test "should redirect new when not logged in" do
    get :new, params: { event: @event }
    assert_redirected_to login_url
  end

  # NEW_FLIGHT_SEARCH

  test "should get new flight search for correct user" do
    log_in_as(users(:johndoe))
    get :new_flight_search, params: { id: travelers(:one) }
    assert_response :success
  end
  
  test "should redirect new flight search for incorrect user" do
    log_in_as(users(:archer))
    get :new_flight_search, params: { id: travelers(:one) }
    assert_redirected_to root_url
  end

  test "should redirect new flight search when not logged in" do
    get :new_flight_search, params: { id: travelers(:one) }
    assert_redirected_to login_url
  end

  # NEW_FLIGHT_SELECT

  # test "should get new flight select for correct user" do
    # This test won't work because it's dependent on a successful result from an external resource.
  # end

  test "should redirect new flight select for incorrect user" do
    log_in_as(users(:archer))
    post :new_flight_select, params: { id: travelers(:one), airline_code: "AA", flight_number: "1234", departure_date: Date.today }
    assert_redirected_to root_url
  end

  test "should redirect new flight select when not logged in" do
    post :new_flight_select, params: { id: travelers(:one), airline_code: "AA", flight_number: "1234", departure_date: Date.today }
    assert_redirected_to login_url
  end

  # CREATE

  test "should create traveler for correct user" do
    log_in_as(users(:johndoe))
    assert_difference "Traveler.count", 1 do
      post :create, params: { traveler: { traveler_name: "Bob Smith", traveler_note: "bsmith", event: @event} }
    end
    assert_redirected_to @event
  end
  
  test "should redirect create for incorrect user" do
    log_in_as(users(:johndoe))
    event = events(:different_owner)
    assert_no_difference "Traveler.count" do
      post :create, params: { traveler: { traveler_name: "Bob Smith", traveler_note: "bsmith", event: event} }
    end
    assert_redirected_to root_url
  end

  test "should redirect create when not logged in" do
    assert_no_difference "Traveler.count" do
      post :create, params: { traveler: { traveler_name: "John Doe", traveler_note: "jdoe", event: @event } }
    end
    assert_redirected_to login_url
  end

  # EDIT

  test "should get edit for correct user" do
    log_in_as(users(:johndoe))
    get :edit, params: { id: travelers(:one) }
    assert_response :success
  end

  test "should redirect edit for incorrect user" do
    log_in_as(users(:archer))
    get :edit, params: { id: travelers(:one) }
    assert_redirected_to root_url
  end

  test "should redirect edit when not logged in" do
    get :edit, params: { id: travelers(:one) }
    assert_redirected_to login_url
  end

  # UPDATE

  test "should update traveler for correct user" do
    log_in_as(users(:johndoe))
    patch :update, params: { id: travelers(:one), traveler: { traveler_name: "Foo Bar" }}
    assert_redirected_to @event
  end

  test "should redirect update for incorrect user" do
    log_in_as(users(:archer))
    patch :update, params: { id: travelers(:one), traveler: { traveler_name: "Foo Bar" }}
    assert_redirected_to root_url
  end

  test "should redirect update when not logged in" do
    patch :update, params: { id: travelers(:one), traveler: { traveler_name: "Foo Bar" }}
    assert_redirected_to login_url
  end

  # DESTROY
  
  test "should destroy traveler for correct user" do
    log_in_as(users(:johndoe))
    assert_difference "Traveler.count", -1 do
      delete :destroy, params: { id: travelers(:one) }
    end
    assert_redirected_to @event
  end
  
  test "should redirect destroy for incorrect user" do
    log_in_as(users(:archer))
    assert_no_difference "Traveler.count" do
      delete :destroy, params: { id: travelers(:one) }
    end
    assert_redirected_to root_url
  end

  test "should redirect destroy when not logged in" do
    assert_no_difference "Traveler.count" do
      delete :destroy, params: { id: travelers(:one) }
    end
    assert_redirected_to login_url
  end
  
end


