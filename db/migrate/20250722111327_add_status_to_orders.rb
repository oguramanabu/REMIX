class AddStatusToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :status, :string, default: 'draft', null: false
    add_index :orders, :status
  end
end
