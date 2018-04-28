require "test_helper"

class SectionsControllerTest < ActionController::TestCase
  def setup
    @event = events(:one)
  end
  
  test "should redirect create when not logged in" do
    assert_no_difference "Section.count" do
      post :create, params: { section: { traveler_name: "John Doe", traveler_note: "jdoe", pickup_info: "Rental Car", is_arrival: true}, event: @event }
    end
    assert_redirected_to login_url
  end
  
  test "should redirect create for wrong section" do
    log_in_as(users(:johndoe))
    event = events(:different_owner)
    assert_no_difference "Section.count" do
      post :create, params: { section: { traveler_name: "Bob Smith", traveler_note: "bsmith", pickup_info: "Rental Car", is_arrival: true}, event: event }
    end
    assert_redirected_to root_url
  end
  
  test "should redirect destroy for wrong section" do
    log_in_as(users(:johndoe))
    section = sections(:two)
    assert_no_difference "Section.count" do
      delete :destroy, params: { id: section }
    end
    assert_redirected_to root_url
  end
  
end


