class AddNameFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :family_name_eng, :string
    add_column :users, :given_name_eng, :string
    add_column :users, :family_name_kanji, :string
    add_column :users, :given_name_kanji, :string
  end
end
