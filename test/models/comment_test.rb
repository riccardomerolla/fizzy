require "test_helper"

class CommentTest < ActiveSupport::TestCase
  setup do
    Current.session = sessions(:david)
  end

  test "searchable by body" do
    message = cards(:logo).capture Comment.new(body: "I'd prefer something more rustic")

    assert_includes Comment.search("something rustic"), message.comment
  end
end
