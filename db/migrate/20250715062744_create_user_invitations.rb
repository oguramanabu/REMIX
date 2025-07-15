class CreateUserInvitations < ActiveRecord::Migration[8.0]
  def change
    create_table :user_invitations do |t|
      t.string :email_address, null: false
      t.references :invited_by, null: false, foreign_key: { to_table: :users }
      t.datetime :invited_at, null: false
      t.datetime :accepted_at
      t.string :token, null: false

      t.timestamps
    end
    add_index :user_invitations, :email_address, unique: true
    add_index :user_invitations, :token, unique: true
  end
end
