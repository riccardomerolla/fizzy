class AddQueenbeeIdToAccounts < ActiveRecord::Migration[8.1]
  def change
    add_column :accounts, :queenbee_id, :integer # I solemnly swear I will add a "NOT NULL" constraint once it's populated
    add_index :accounts, :queenbee_id, unique: true
  end
end
