require "test_helper"

class CareerOfficer::JobFairArenaControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get career_officer_job_fair_arena_index_url
    assert_response :success
  end

  test "should get show" do
    get career_officer_job_fair_arena_show_url
    assert_response :success
  end
end
