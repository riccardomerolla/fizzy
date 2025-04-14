module CardScoped
  extend ActiveSupport::Concern

  included do
    before_action :set_card, :set_collection
  end

  private
    def set_card
      @card = Current.user.accessible_cards.find(params[:card_id])
    end

    def set_collection
      @collection = @card.collection
    end
end
