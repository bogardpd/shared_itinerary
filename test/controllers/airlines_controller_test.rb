require 'test_helper'

class AirlinesControllerTest < ActionController::TestCase
  
  def setup
    @user = users(:johndoe)
    @other_user = users(:archer)
    @airline = airlines(:panam)
  end
  
  test "should get index when logged in as an admin" do
    log_in_as(@user)
    get :index
    assert_response :success
  end
  
  test "should redirect index when logged in as a non-admin" do
    log_in_as(@other_user)
    get :index
    assert_redirected_to root_url
  end
  
  test "should get edit when logged in as an admin" do
    log_in_as(@user)
    get :edit, id: @airline
    assert_response :success
  end
  
  test "should redirect edit when logged in as a non-admin" do
    log_in_as(@other_user)
    get :edit, id: @airline
    assert_redirected_to root_url
  end
  
  test "should redirect update when not logged in" do
    patch :update, id: @airline, airline: { name: "TWA" }
    assert_not flash.empty?
    assert_redirected_to login_url
  end
  
  test "should redirect update when logged in as a non-admin" do
    log_in_as(@other_user)
    patch :update, id: @airline, airline: { name: "TWA" }
    assert_redirected_to root_url
  end
  
end
