require "test_helper"

class CareerOfficer::MeetingsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get career_officer_meetings_index_url
    assert_response :success
  end

  test "should get new" do
    get career_officer_meetings_new_url
    assert_response :success
  end

  test "should get create" do
    get career_officer_meetings_create_url
    assert_response :success
  end

  test "should get edit" do
    get career_officer_meetings_edit_url
    assert_response :success
  end

  test "should get update" do
    get career_officer_meetings_update_url
    assert_response :success
  end

  test "should get destroy" do
    get career_officer_meetings_destroy_url
    assert_response :success
  end
end
