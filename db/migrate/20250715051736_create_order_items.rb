class CreateOrderItems < ActiveRecord::Migration[8.0]
  def change
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.string :name
      t.integer :quantity
      t.decimal :unit_price

      t.timestamps
    end
  end
end
