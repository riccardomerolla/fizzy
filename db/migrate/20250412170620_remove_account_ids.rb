class RemoveAccountIds < ActiveRecord::Migration[8.1]
  def change
    remove_column :closure_reasons, :account_id
    remove_column :collections, :account_id
    remove_column :tags, :account_id
    remove_column :users, :account_id
    remove_column :workflows, :account_id
  end
end
