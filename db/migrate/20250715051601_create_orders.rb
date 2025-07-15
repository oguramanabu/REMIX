class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.string :client
      t.string :factory_name
      t.date :order_date
      t.date :shipping_date
      t.date :delivery_date

      t.timestamps
    end
  end
end
