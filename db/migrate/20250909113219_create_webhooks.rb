class CreateWebhooks < ActiveRecord::Migration[8.1]
  def change
    create_table :webhooks do |t|
      t.boolean :active, default: true, null: false
      t.string :name
      t.text :url, null: false
      t.text :subscribed_actions, index: true
      t.string :signing_secret, null: false

      t.timestamps
    end
  end
end
