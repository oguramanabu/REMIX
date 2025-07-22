class ChangeAttachmentUrlToArrayInOrders < ActiveRecord::Migration[8.0]
  def change
    remove_column :orders, :attachment_url, :string
    add_column :orders, :attachment_urls, :text, array: true, default: []
  end
end
