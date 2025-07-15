class AddCreatorToOrders < ActiveRecord::Migration[8.0]
  def change
    add_reference :orders, :creator, null: true, foreign_key: { to_table: :users }

    # Set default creator for existing orders
    if User.exists?
      first_user = User.first
      execute "UPDATE orders SET creator_id = #{first_user.id} WHERE creator_id IS NULL"
    end

    change_column_null :orders, :creator_id, false
  end
end
