require "test_helper"

class EventsControllerTest < ActionController::TestCase
  
  def setup
    @event = events(:one)
  end
  
  test "should redirect create when not logged in" do
    assert_no_difference "Event.count" do
      post :create, params: { event: { event_name: "Convention", arriving_timezone: "EST", departing_timezone: "EST" } }
    end
    assert_redirected_to login_url
  end
  
  test "should redirect destroy when not logged in" do
    assert_no_difference "Event.count" do
      delete :destroy, params: { id: @event }
    end
    assert_redirected_to login_url
  end
  
  test "should redirect destroy for wrong event" do
    log_in_as(users(:johndoe))
    event = events(:different_owner)
    assert_no_difference "Event.count" do
      delete :destroy, params: { id: event }
    end
    assert_redirected_to root_url
  end
  
  test "should redirect show when not logged in and with no share link" do
    get :show, params: { id: @event }
    assert_redirected_to login_url
  end
  
  test "should redirect show when logged in as wrong user and with no share link" do
    log_in_as(users(:archer))
    get :show, params: { id: @event }
    assert_redirected_to root_url
  end
  
  test "should redirect show when not logged in and with wrong share link" do
    get :show, params: { id: @event, share_link: "badc0ffee" }
    assert_redirected_to login_url
  end
  
  test "should redirect show when logged in as wrong user with wrong share link" do
    log_in_as(users(:archer))
    get :show, params: { id: @event, share_link: "badc0ffee" }
    assert_redirected_to root_url
  end
  
  test "should allow show when not logged in and with correct share link" do
    get :show, params: { id: @event, share_link: "c0ffee" }
    assert_response :success
  end
  
  test "should allow show when logged in as wrong user with correct share link" do
    log_in_as(users(:archer))
    get :show, params: { id: @event, share_link: "c0ffee" }
    assert_response :success
  end
  
end
