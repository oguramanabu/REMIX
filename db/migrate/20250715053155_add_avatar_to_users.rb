class AddAvatarToUsers < ActiveRecord::Migration[8.0]
  def change
    # Avatar will be handled by Active Storage
    # No schema changes needed - Active Storage uses its own tables
  end
end
