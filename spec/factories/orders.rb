FactoryBot.define do
  factory :order do
    client { "MyString" }
    factory_name { "MyString" }
    order_date { "2025-07-15" }
    shipping_date { "2025-07-15" }
    delivery_date { "2025-07-15" }
  end
end
