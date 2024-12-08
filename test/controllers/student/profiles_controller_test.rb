require "test_helper"

class Student::ProfilesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get student_profiles_show_url
    assert_response :success
  end

  test "should get edit" do
    get student_profiles_edit_url
    assert_response :success
  end
end
