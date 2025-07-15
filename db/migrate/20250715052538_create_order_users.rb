class CreateOrderUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :order_users do |t|
      t.references :order, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :order_users, [ :order_id, :user_id ], unique: true
  end
end
