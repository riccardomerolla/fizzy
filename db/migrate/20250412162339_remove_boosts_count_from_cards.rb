class RemoveBoostsCountFromCards < ActiveRecord::Migration[8.1]
  def change
    remove_column :cards, :boosts_count
  end
end
