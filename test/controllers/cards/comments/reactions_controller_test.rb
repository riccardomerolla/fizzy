require "test_helper"

class Cards::Comments::ReactionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as :jz
    @comment = comments(:logo_agreement_jz)
    @card = @comment.card
  end

  test "create" do
    assert_turbo_stream_broadcasts @card, count: 1 do
      assert_difference -> { @comment.reactions.count }, 1 do
        post card_comment_reactions_path(@comment.card, @comment, format: :turbo_stream), params: { reaction: { content: "Great work!" } }
        assert_redirected_to card_comment_reactions_path(@comment.card, @comment)
      end
    end
  end

  test "destroy" do
    assert_turbo_stream_broadcasts @card, count: 1 do
      assert_difference -> { @comment.reactions.count }, -1 do
        delete card_comment_reaction_path(@comment.card, @comment, reactions(:kevin), format: :turbo_stream)
        assert_response :success
      end
    end
  end
end
