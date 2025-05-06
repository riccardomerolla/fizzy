class CreateCommands < ActiveRecord::Migration[8.1]
  def change
    create_table :commands do |t|
      t.references :user, null: false, foreign_key: true, index: true
      t.string :type
      t.json :data, default: {}

      t.timestamps

      t.index %i[ user_id created_at ]
    end
  end
end
