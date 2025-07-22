class AddAdditionalColumnsToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :item_number, :string
    add_column :orders, :item_name, :string
    add_column :orders, :quantity, :integer
    add_column :orders, :trade_term, :string
    add_column :orders, :purchase_price, :decimal, precision: 10, scale: 2
    add_column :orders, :sell_price, :integer
    add_column :orders, :export_port, :string
    add_column :orders, :estimate_delivery_date, :date
    add_column :orders, :sales_multiple, :decimal, precision: 10, scale: 4
    add_column :orders, :exchange_rate, :integer
    add_column :orders, :license, :string
  end
end
