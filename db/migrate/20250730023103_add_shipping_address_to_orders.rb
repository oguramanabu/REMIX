class AddShippingAddressToOrders < ActiveRecord::Migration[8.0]
  def change
    add_reference :orders, :shipping_address, null: true, foreign_key: true
  end
end
