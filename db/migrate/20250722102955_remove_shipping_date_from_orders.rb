class RemoveShippingDateFromOrders < ActiveRecord::Migration[8.0]
  def change
    remove_column :orders, :shipping_date, :date
  end
end
