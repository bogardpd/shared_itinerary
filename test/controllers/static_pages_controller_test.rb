require 'test_helper'

class StaticPagesControllerTest < ActionController::TestCase
  
  def setup
    @base_title = "Shared Itinerary"
    @user = users(:johndoe)
    @other_user = users(:archer)
  end
  
  test "should get home" do
    get :home
    assert_response :success
    assert_select "title", "#{@base_title}"
  end
  
  test "should get admin control panel when logged in as an admin" do
    log_in_as(@user)
    get :admin
    assert_response :success
  end
  
  test "should redirect admin control panel when logged in as a non-admin" do
    log_in_as(@other_user)
    get :admin
    assert_redirected_to root_url
  end

  test "should redirect google autocomplete api proxy when not logged in" do
    get :google_places_api_proxy, params: {term: "tuc"}
    assert_redirected_to login_url
  end

  test "should redirect google timezone api proxy when not logged in" do
    get :google_timezone_api_proxy, params: {place_id: "ChIJK-0sC0Fl1oYRFccWTTgtw3M"}
    assert_redirected_to login_url
  end

end
