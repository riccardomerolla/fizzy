require "test_helper"

class Public::Collections::Columns::NotNowsControllerTest < ActionDispatch::IntegrationTest
  setup do
    collections(:writebook).publish
  end

  test "show" do
    get public_collection_columns_not_now_path(collections(:writebook).publication.key)
    assert_response :success
  end
end
