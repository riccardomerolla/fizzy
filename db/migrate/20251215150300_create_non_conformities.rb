class CreateNonConformities < ActiveRecord::Migration[8.2]
  def change
    create_table :non_conformities, id: :uuid do |t|
      t.uuid :account_id, null: false
      t.uuid :reprocessing_cycle_id, null: false
      t.string :kind, null: false
      t.text :notes
      t.datetime :occurred_at, null: false
      t.timestamps

      t.index :account_id
      t.index :reprocessing_cycle_id
      t.index [ :account_id, :kind ], name: "index_non_conformities_on_account_kind"
      t.index [ :account_id, :occurred_at ], name: "index_non_conformities_on_account_occurred"
    end
  end
end
