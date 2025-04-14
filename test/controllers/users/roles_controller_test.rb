require "test_helper"

class Users::RolesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as :kevin
  end

  test "update" do
    assert_not users(:david).admin?

    put user_role_path(users(:david)), params: { user: { role: "admin" } }

    assert_redirected_to users_path
    assert users(:david).reload.admin?
  end

  test "can't promote to special roles" do
    assert_no_changes -> { users(:david).reload.role } do
      put user_role_path(users(:david)), params: { user: { role: "system" } }
    end
  end
end
