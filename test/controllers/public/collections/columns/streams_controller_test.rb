require "test_helper"

class Public::Collections::Columns::StreamsControllerTest < ActionDispatch::IntegrationTest
  setup do
    collections(:writebook).publish
  end

  test "show" do
    get public_collection_columns_stream_path(collections(:writebook).publication.key)
    assert_response :success
  end
end
