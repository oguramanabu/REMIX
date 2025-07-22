class AddAttachmentFieldsToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :attachment_url, :string
  end
end
