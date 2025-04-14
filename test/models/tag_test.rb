require "test_helper"

class TagTest < ActiveSupport::TestCase
  test "downcase title" do
    assert_equal "a tag", Tag.create!(title: "A TAG").title
  end
end
