class CreateChatMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :chat_messages do |t|
      t.references :order, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :content, null: false
      t.text :mentioned_users  # JSON array of mentioned user IDs
      t.boolean :is_system_message, default: false

      t.timestamps
    end

    add_index :chat_messages, [ :order_id, :created_at ]
  end
end
