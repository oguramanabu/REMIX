class AddClientIdToOrders < ActiveRecord::Migration[8.0]
  def change
    add_reference :orders, :client, null: true, foreign_key: true

    # Update existing orders to link to clients based on the string client field
    reversible do |dir|
      dir.up do
        Order.reset_column_information
        Client.reset_column_information

        Order.find_each do |order|
          if order.client.present?
            client = Client.find_by(name: order.client)
            if client
              order.update_column(:client_id, client.id)
            end
          end
        end
      end
    end
  end
end
