class CreateCsvImportErrors < ActiveRecord::Migration[8.2]
  def change
    create_table :csv_import_errors, id: :uuid do |t|
      t.uuid :csv_import_id, null: false
      t.integer :row_number, null: false
      t.text :message, null: false
      t.json :raw_row
      t.timestamps

      t.index :csv_import_id
    end
  end
end
