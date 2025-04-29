class FlattenMessagesAndComments < ActiveRecord::Migration[8.1]
  def change
    add_reference :comments, :card, null: true, foreign_key: true

    execute <<~SQL
      UPDATE comments
      SET card_id = (
        SELECT messages.card_id
        FROM messages
        WHERE messages.messageable_type = 'Comment'
          AND messages.messageable_id = comments.id
        LIMIT 1
      )
    SQL

    change_column_null :comments, :card_id, false
    drop_table :messages
  end
end
