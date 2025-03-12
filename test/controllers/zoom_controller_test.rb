require "test_helper"

class ZoomControllerTest < ActionDispatch::IntegrationTest
  test "should get auth" do
    get zoom_auth_url
    assert_response :success
  end

  test "should get callback" do
    get zoom_callback_url
    assert_response :success
  end
end
