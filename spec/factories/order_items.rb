FactoryBot.define do
  factory :order_item do
    order { nil }
    name { "MyString" }
    quantity { 1 }
    unit_price { "9.99" }
  end
end
