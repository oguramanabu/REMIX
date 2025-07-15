FactoryBot.define do
  factory :user_invitation do
    email_address { "MyString" }
    invited_by { nil }
    invited_at { "2025-07-15 15:27:44" }
    accepted_at { "2025-07-15 15:27:44" }
    token { "MyString" }
  end
end
