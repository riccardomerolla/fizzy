class CreateWebhookDeliveries < ActiveRecord::Migration[8.1]
  def change
    create_table :webhook_deliveries do |t|
      t.belongs_to :webhook, null: false, foreign_key: true
      t.belongs_to :event, null: false, foreign_key: true
      t.string :state, null: false
      t.text :request
      t.text :response

      t.timestamps
    end
  end
end
