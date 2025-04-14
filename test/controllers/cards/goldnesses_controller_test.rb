require "test_helper"

class Cards::GoldnessesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as :kevin
  end

  test "create" do
    card = cards(:text)

    assert_changes -> { card.reload.golden? }, from: false, to: true do
      post card_goldness_path(card)
    end

    assert_redirected_to collection_card_path(card.collection, card)
  end

  test "destroy" do
    card = cards(:logo)

    assert_changes -> { card.reload.golden? }, from: true, to: false do
      delete card_goldness_path(card)
    end

    assert_redirected_to collection_card_path(card.collection, card)
  end
end
