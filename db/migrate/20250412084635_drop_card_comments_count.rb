class DropCardCommentsCount < ActiveRecord::Migration[8.1]
  def change
    remove_column :cards, :comments_count
  end
end
