require "test_helper"

class CareerOfficer::StudentProfilesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get career_officer_student_profiles_index_url
    assert_response :success
  end
end
