require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as :kevin
  end

  test "update" do
    assert true
  end

  test "destroy" do
    assert_difference -> { User.active.count }, -1 do
      delete user_path(users(:david))
    end

    assert_redirected_to users_path
    assert_nil User.active.find_by(id: users(:david).id)
  end

  test "non-admins cannot perform actions" do
    sign_in_as :jz

    put user_path(users(:david)), params: { user: { role: "admin" } }
    assert_response :forbidden

    delete user_path(users(:david))
    assert_response :forbidden
  end
end
