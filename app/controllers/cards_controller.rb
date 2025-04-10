require "ostruct"

class CardsController < ApplicationController
  include CollectionScoped, FilterScoped

  skip_before_action :set_collection, only: :index
  before_action :set_card, only: %i[ show edit update destroy ]

  PAGE_SIZE = 50

  def index
    @considering = page_and_filter_for @filter.with(engagement_status: "considering", indexed_by: "latest"), per_page: PAGE_SIZE
    @doing = page_and_filter_for @filter.with(engagement_status: "doing", indexed_by: "latest"), per_page: PAGE_SIZE
    @closed = page_and_filter_for @filter.with(indexed_by: "closed"), per_page: PAGE_SIZE
  end

  def create
    redirect_to @collection.cards.create!
  end

  def show
  end

  def edit
  end

  def destroy
    @card.destroy!
    redirect_to cards_path(collection_ids: [ @card.collection ]), notice: deleted_notice
  end

  def update
    @card.update! card_params
    redirect_to @card
  end

  private
    def set_card
      @card = @collection.cards.find params[:id]
    end

    def page_and_filter_for(filter, per_page: nil, cards: filter.cards)
      OpenStruct.new \
        page: GearedPagination::Recordset.new(cards, per_page:).page(1),
        filter: filter
    end

    def card_params
      params.expect(card: [ :status, :title, :color, :due_on, :image, :draft_comment, tag_ids: [] ])
    end

    def deleted_notice
      "Card deleted" unless @card.creating?
    end
end
