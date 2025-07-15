class AddCancelledAtToUserInvitations < ActiveRecord::Migration[8.0]
  def change
    add_column :user_invitations, :cancelled_at, :datetime
  end
end
