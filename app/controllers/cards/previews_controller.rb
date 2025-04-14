class Cards::PreviewsController < ApplicationController
  include FilterScoped

  before_action :set_filter, only: :index

  def index
    set_page_and_extract_portion_from @filter.cards, per_page: CardsController::PAGE_SIZE
  end
end
