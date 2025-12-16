class CreateContracts < ActiveRecord::Migration[8.2]
  def change
    create_table :contracts, id: :uuid do |t|
      t.uuid :account_id, null: false
      t.uuid :site_id
      t.string :name, null: false
      
      # Pricing rules
      t.integer :price_per_set_cents, null: false, default: 0
      t.boolean :exclude_nonconform, null: false, default: true
      
      # SLA settings
      t.integer :sla_turnaround_hours
      t.integer :penalty_per_breach_cents
      
      t.timestamps

      t.index :account_id
      t.index :site_id
      t.index [ :account_id, :site_id ], name: "index_contracts_on_account_site"
    end
  end
end
