class CreateSetCatalogs < ActiveRecord::Migration[8.2]
  def change
    create_table :set_catalogs, id: :uuid do |t|
      t.uuid :account_id, null: false
      t.string :catalog_barcode, null: false
      t.string :name, null: false
      t.string :family
      t.timestamps

      t.index :account_id
      t.index [ :account_id, :catalog_barcode ], unique: true
    end
  end
end
