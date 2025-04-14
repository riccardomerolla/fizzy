require "test_helper"

class Card::ScorableTest < ActiveSupport::TestCase
  test "cards with no activity have a valid activity_score_order" do
    card = Card.create! collection: collections(:writebook), creator: users(:kevin)

    card.rescore

    assert card.activity_score.zero?
    assert_not card.activity_score_order.infinite?
  end
end
