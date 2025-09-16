class ConversationsController < ApplicationController
  before_action :ensure_is_staff_member

  def create
    Current.user.start_or_continue_conversation
  end

  def show
    @conversation = Current.user.conversation
  end
end
