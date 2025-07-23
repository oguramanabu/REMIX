FactoryBot.define do
  factory :chat_message do
    order { nil }
    user { nil }
    content { "MyText" }
    mentioned_users { "MyText" }
    created_at { "2025-07-22 20:45:08" }
    updated_at { "2025-07-22 20:45:08" }
  end
end
