require "test_helper"

class BubbleTest < ActiveSupport::TestCase
  test "searchable by title" do
    bubble = buckets(:writebook).bubbles.create! title: "Insufficient haggis", creator: users(:kevin)

    assert_includes Bubble.search("haggis"), bubble
  end

  test "mentioning" do
    bubble = buckets(:writebook).bubbles.create! title: "Insufficient haggis", creator: users(:kevin)
    bubbles(:logo).comments.create! body: "I hate haggis", creator: users(:kevin)
    bubbles(:text).comments.create! body: "I love haggis", creator: users(:kevin)

    assert_equal [ bubble, bubbles(:logo), bubbles(:text) ].sort, Bubble.mentioning("haggis").sort
  end
end
