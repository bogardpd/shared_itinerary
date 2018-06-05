require 'test_helper'

class AirlinesControllerTest < ActionController::TestCase
  
  def setup
    @admin_user = users(:johndoe)
    @other_user = users(:archer)
    @airline = airlines(:panam)
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
  
  test "should get edit when logged in as an admin" do
    log_in_as(@admin_user)
    get :edit, params: { id: @airline }
    assert_response :success
  end
  
  test "should redirect edit when logged in as a non-admin" do
    log_in_as(@other_user)
    get :edit, params: { id: @airline }
    assert_redirected_to root_url
  end
  
  test "should redirect update when logged in as a non-admin" do
    log_in_as(@other_user)
    patch :update, params: { id: @airline, airline: { name: "TWA" } }
    assert_redirected_to root_url
  end
  
  test "should redirect update when not logged in" do
    patch :update, params: { id: @airline, airline: { name: "TWA" } }
    assert_not flash.empty?
    assert_redirected_to login_url
  end
  
end
