require "test_helper"

class Recruiter::ProfilesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get recruiter_profiles_show_url
    assert_response :success
  end

  test "should get edit" do
    get recruiter_profiles_edit_url
    assert_response :success
  end
end
