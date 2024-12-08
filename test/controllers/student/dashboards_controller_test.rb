require "test_helper"

class Student::DashboardsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get student_dashboards_index_url
    assert_response :success
  end
end
