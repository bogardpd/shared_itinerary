require "test_helper"

class EventsControllerTest < ActionController::TestCase
  
  def setup
    @event = events(:one)
  end
  
  # SHOW

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

  # NEW

  test "should get new when logged in" do
    log_in_as(users(:archer))
    get :new
    assert_response :success
  end

  test "should redirect new when not logged in" do
    get :new
    assert_redirected_to login_url
  end

  # CREATE

  test "should create event when logged in" do
    log_in_as(users(:johndoe))
    assert_difference "Event.count", 1 do
      post :create, params: { event: { event_name: "Convention", timezone: "America/New_York" } }
    end
    assert_redirected_to users(:johndoe)
  end

  test "should redirect create when not logged in" do
    assert_no_difference "Event.count" do
      post :create, params: { event: { event_name: "Convention", timezone: "America/New_York" } }
    end
    assert_redirected_to login_url
  end

  # EDIT

  test "should get edit when logged in as correct user" do
    log_in_as(users(:johndoe))
    get :edit, params: { id: @event }
    assert_response :success
  end

  test "should redirect edit when logged in as incorrect user" do
    log_in_as(users(:archer))
    get :edit, params: { id: @event }
    assert_redirected_to root_url
  end

  test "should redirect edit when not logged in" do
    get :edit, params: { id: @event }
    assert_redirected_to login_url
  end

  # UPDATE

  test "should update event when logged in as correct user" do
    log_in_as(users(:johndoe))
    patch :update, params: { id: @event, event: { event_name: "New Name" }}
    assert_redirected_to @event
  end

  test "should redirect update when logged in as incorrect user" do
    log_in_as(users(:archer))
    patch :update, params: { id: @event, event: { event_name: "New Name" }}
    assert_redirected_to root_url
  end

  test "should redirect update when not logged in" do
    patch :update, params: { id: @event, event: { event_name: "New Name" }}
    assert_redirected_to login_url
  end

  # UPDATE_SHARE_LINK

  test "should update share link when logged in as correct user" do
    log_in_as(users(:johndoe))
    post :update_share_link, params: { id: @event }
    assert_redirected_to @event
  end

  test "should redirect update share link when logged in as incorrect user" do
    log_in_as(users(:archer))
    post :update_share_link, params: { id: @event }
    assert_redirected_to root_url
  end

  test "should redirect update share link when not logged in" do
    post :update_share_link, params: { id: @event }
    assert_redirected_to login_url
  end

  # DESTROY

  test "should destroy event when logged in as correct user" do
    log_in_as users(:johndoe)
    assert_difference "Event.count", -1 do
      delete :destroy, params: {id: @event }
    end
    assert_redirected_to users(:johndoe)
  end
  
  test "should redirect destroy when logged in as incorrect user" do
    log_in_as(users(:johndoe))
    assert_no_difference "Event.count" do
      delete :destroy, params: { id: events(:different_owner) }
    end
    assert_redirected_to root_url
  end

  test "should redirect destroy when not logged in" do
    assert_no_difference "Event.count" do
      delete :destroy, params: { id: @event }
    end
    assert_redirected_to login_url
  end
  
end
