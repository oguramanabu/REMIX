class CreateShippingAddresses < ActiveRecord::Migration[8.0]
  def change
    create_table :shipping_addresses do |t|
      t.references :client, null: false, foreign_key: true
      t.text :address
      t.string :name

      t.timestamps
    end
  end
end
