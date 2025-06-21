class ChangeNameFieldsToNotNullInUsers < ActiveRecord::Migration[8.0]
  def change
    # Update existing records with default values
    User.update_all(
      family_name_eng: 'Unknown',
      given_name_eng: 'User',
      family_name_kanji: '不明',
      given_name_kanji: 'ユーザー'
    )
    
    # Now make the columns NOT NULL
    change_column_null :users, :family_name_eng, false
    change_column_null :users, :given_name_eng, false
    change_column_null :users, :family_name_kanji, false
    change_column_null :users, :given_name_kanji, false
  end
end
