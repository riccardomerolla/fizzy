require "test_helper"

class Notifications::TraysControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as :kevin
  end

  test "show" do
    get notifications_tray_path

    assert_response :success
    assert_select "div", text: /Layout is broken/
  end
end
