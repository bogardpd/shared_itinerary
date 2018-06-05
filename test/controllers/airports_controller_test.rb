require "test_helper"

class AirportsControllerTest < ActionController::TestCase
  
  def setup
    @admin_user = users(:johndoe)
    @other_user = users(:archer)
    @airport = airports(:atlanta)
  end
  
  test "should get index when logged in as an admin" do
    log_in_as(@admin_user)
    get :index
    assert_response :success
  end
  
  test "should redirect index when logged in as a non-admin" do
    log_in_as(@other_user)
    get :index
    assert_redirected_to root_url
  end
  
  test "should redirect index when not logged in" do
    get :index
    assert_redirected_to login_url
  end
  
  test "should get new when logged in as admin" do
    log_in_as(@admin_user)
    get :new
    assert_response :success
  end
  
  test "should redirect new when logged in as a non-admin" do
    log_in_as(@other_user)
    get :new
    assert_redirected_to root_url
  end
  
  test "should redirect new when not logged in" do
    get :new
    assert_redirected_to login_url
  end
  
  test "should redirect create when logged in as non-admin" do
    log_in_as(@other_user)
    post :create, params: { airport: { name: "Chicago", iata_code: "ORD", icao_code: "KORD", timezone: "America/Chicago"}}
    assert_redirected_to root_url
  end
  
  test "should redirect create when not logged in" do
    post :create, params: { airport: { name: "Chicago", iata_code: "ORD", icao_code: "KORD", timezone: "America/Chicago"}}
    assert_redirected_to login_url    
  end
  
  test "should get edit when logged in as an admin" do
    log_in_as(@admin_user)
    get :edit, params: { id: @airport }
    assert_response :success
  end
  
  test "should redirect edit when logged in as a non-admin" do
    log_in_as(@other_user)
    get :edit, params: { id: @airport }
    assert_redirected_to root_url
  end
  
  test "should redirect edit when not logged in" do
    get :edit, params: { id: @airport }
    assert_redirected_to login_url
  end
  
  test "should redirect update when logged in as a non-admin" do
    log_in_as(@other_user)
    patch :update, params: { id: @airport, airport: { name: "Atlanta2" } }
    assert_redirected_to root_url
  end
  
  test "should redirect update when not logged in" do
    patch :update, params: { id: @airport, airport: { name: "Atlanta2" } }
    assert_not flash.empty?
    assert_redirected_to login_url
  end
  
end
