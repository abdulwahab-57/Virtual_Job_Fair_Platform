require "test_helper"

class Recruiter::VirtualBoothControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get recruiter_virtual_booth_index_url
    assert_response :success
  end

  test "should get show" do
    get recruiter_virtual_booth_show_url
    assert_response :success
  end
end
