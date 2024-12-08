require "test_helper"

class Recruiter::DashboardsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get recruiter_dashboards_index_url
    assert_response :success
  end
end
