module Card::Messages
  extend ActiveSupport::Concern

  included do
    has_many :messages, -> { chronologically }, dependent: :destroy
  end

  def capture(messageable)
    messages.create! messageable: messageable
  end
end
