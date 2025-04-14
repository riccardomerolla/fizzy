class Cards::StagingsController < ApplicationController
  include CardScoped

  before_action :set_stage

  def create
    if @stage
      @card.toggle_stage @stage
    else
      @card.update!(stage: nil)
    end
  end

  private
    def set_stage
      @stage = Workflow::Stage.find_by(id: params[:stage_id])
    end
end
