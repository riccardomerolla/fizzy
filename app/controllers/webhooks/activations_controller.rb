class Webhooks::ActivationsController < ApplicationController
  before_action :ensure_can_administer
  before_action :set_webhook

  def create
    @webhook.activate unless @webhook.active?
    redirect_to @webhook, status: :see_other
  end

  private
    def set_webhook
      @webhook = Webhook.find(params[:webhook_id])
    end
end
