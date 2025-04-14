module CommentsHelper
  def new_comment_placeholder(card)
    if card.creator == Current.user && card.messages.comments.empty?
      "Next, add some notes, context, pictures, or video about this…"
    else
      "Type your comment…"
    end
  end
end
