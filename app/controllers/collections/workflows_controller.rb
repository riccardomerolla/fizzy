class Collections::WorkflowsController < ApplicationController
  include CollectionScoped

  before_action :set_workflow

  def update
    @collection.update! workflow: @workflow
    redirect_to edit_collection_path(@collection), notice: "Collection updated"
  end

  private
    def set_workflow
      @workflow = Workflow.find(params[:collection][:workflow_id])
    end
end
