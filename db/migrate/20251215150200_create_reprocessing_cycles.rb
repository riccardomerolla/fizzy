class CreateReprocessingCycles < ActiveRecord::Migration[8.2]
  def change
    create_table :reprocessing_cycles, id: :uuid do |t|
      t.uuid :account_id, null: false
      t.uuid :site_id, null: false
      t.uuid :set_catalog_id, null: false
      t.string :cycle_barcode, null: false
      
      # Stage timestamps
      t.datetime :received_at, null: false
      t.datetime :washed_at
      t.datetime :packed_at
      t.datetime :sterilized_at
      t.datetime :delivered_at
      
      # Status and source
      t.string :status, null: false, default: "conform"
      t.string :source, null: false, default: "csv_upload"
      
      t.timestamps

      t.index :account_id
      t.index :site_id
      t.index :set_catalog_id
      t.index [ :account_id, :site_id, :cycle_barcode ], unique: true, name: "index_cycles_on_account_site_barcode"
      t.index [ :account_id, :site_id, :received_at ], name: "index_cycles_on_account_site_received"
      t.index [ :account_id, :status ], name: "index_cycles_on_account_status"
    end
  end
end
