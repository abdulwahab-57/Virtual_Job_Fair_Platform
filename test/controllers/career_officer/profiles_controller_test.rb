require "test_helper"

class CareerOfficer::ProfilesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get career_officer_profiles_show_url
    assert_response :success
  end

  test "should get edit" do
    get career_officer_profiles_edit_url
    assert_response :success
  end
end
