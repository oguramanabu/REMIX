FactoryBot.define do
  factory :shipping_address do
    client { nil }
    address { "MyText" }
    name { "MyString" }
  end
end
