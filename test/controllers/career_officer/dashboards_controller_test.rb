require "test_helper"

class CareerOfficer::DashboardsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get career_officer_dashboards_index_url
    assert_response :success
  end
end
