class CreateInvoicePeriods < ActiveRecord::Migration[8.2]
  def change
    create_table :invoice_periods, id: :uuid do |t|
      t.uuid :account_id, null: false
      t.uuid :contract_id, null: false
      t.integer :year, null: false
      t.integer :month, null: false
      
      # Computed fields (denormalized for performance)
      t.integer :processed_count, default: 0
      t.integer :nonconform_count, default: 0
      t.integer :billable_count, default: 0
      t.integer :sla_breach_count, default: 0
      t.integer :subtotal_cents, default: 0
      t.integer :penalties_cents, default: 0
      t.integer :total_cents, default: 0
      
      t.datetime :computed_at
      t.timestamps

      t.index :account_id
      t.index :contract_id
      t.index [ :account_id, :contract_id, :year, :month ], unique: true, name: "index_invoice_periods_unique"
    end
  end
end
