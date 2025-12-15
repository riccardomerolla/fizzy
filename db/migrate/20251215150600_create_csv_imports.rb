class CreateCsvImports < ActiveRecord::Migration[8.2]
  def change
    create_table :csv_imports, id: :uuid do |t|
      t.uuid :account_id, null: false
      t.uuid :site_id, null: false
      t.string :status, null: false, default: "pending"
      t.string :original_filename
      t.integer :row_count, default: 0
      t.integer :processed_count, default: 0
      t.integer :rejected_count, default: 0
      t.text :error_message
      t.timestamps

      t.index :account_id
      t.index :site_id
      t.index [ :account_id, :status ], name: "index_csv_imports_on_account_status"
    end
  end
end
