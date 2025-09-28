require "test_helper"

class Public::Collections::ColumnsControllerTest < ActionDispatch::IntegrationTest
  setup do
    collections(:writebook).publish
  end

  test "show" do
    column = columns(:writebook_in_progress)
    get public_collection_column_path(collections(:writebook).publication.key, column)
    assert_response :success
  end
end
