class Webhook::CleanupDeliveriesJob < ApplicationJob
  def perform
    ApplicationRecord.with_each_tenant do
      Webhook::Delivery.cleanup
    end
  end
end
