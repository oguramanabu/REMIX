# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

users_data = [
  {
    email_address: "a@a.com",
    password: "pass",
    family_name_eng: "Ogura",
    given_name_eng: "Manabu",
    family_name_kanji: "小椋",
    given_name_kanji: "学"
  },
  {
    email_address: "b@b.com",
    password: "pass",
    family_name_eng: "Kobayashi",
    given_name_eng: "Jun",
    family_name_kanji: "小林",
    given_name_kanji: "潤"
  }
]

users_data.each do |user_data|
  User.find_or_create_by!(email_address: user_data[:email_address]) do |user|
    user.password = user_data[:password]
    user.password_confirmation = user_data[:password]
    user.family_name_eng = user_data[:family_name_eng]
    user.given_name_eng = user_data[:given_name_eng]
    user.family_name_kanji = user_data[:family_name_kanji]
    user.given_name_kanji = user_data[:given_name_kanji]
  end
end

puts "Created #{User.count} users"
