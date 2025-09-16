class AddCollectionIdToWebhooks < ActiveRecord::Migration[8.1]
  def change
    add_reference :webhooks, :collection, null: false, foreign_key: true
  end
end
