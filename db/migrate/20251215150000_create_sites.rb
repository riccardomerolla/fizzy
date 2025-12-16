class CreateSites < ActiveRecord::Migration[8.2]
  def change
    create_table :sites, id: :uuid do |t|
      t.uuid :account_id, null: false
      t.string :name, null: false
      t.string :code, null: false
      t.string :timezone, default: "Europe/Rome", null: false
      t.timestamps

      t.index :account_id
      t.index [ :account_id, :code ], unique: true
    end
  end
end
