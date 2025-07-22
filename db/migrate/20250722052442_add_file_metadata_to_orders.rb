class AddFileMetadataToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :file_metadata, :jsonb, default: {}
  end
end
