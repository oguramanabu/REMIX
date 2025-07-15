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

orders_data = [
  {
    client: "トヨタ自動車",
    factory_name: "愛知工場",
    order_date: Date.new(2025, 7, 1),
    shipping_date: Date.new(2025, 7, 10),
    delivery_date: Date.new(2025, 7, 15),
    items: [
      { name: "エンジン部品A", quantity: 100, unit_price: 15000 },
      { name: "ブレーキパッド", quantity: 50, unit_price: 8000 }
    ]
  },
  {
    client: "日産自動車",
    factory_name: "横浜工場",
    order_date: Date.new(2025, 7, 5),
    shipping_date: Date.new(2025, 7, 20),
    delivery_date: Date.new(2025, 7, 25),
    items: [
      { name: "タイヤホイール", quantity: 200, unit_price: 25000 },
      { name: "ミラー部品", quantity: 80, unit_price: 12000 }
    ]
  },
  {
    client: "ホンダ技研工業",
    factory_name: "埼玉工場",
    order_date: Date.new(2025, 7, 8),
    shipping_date: nil,
    delivery_date: Date.new(2025, 8, 5),
    items: [
      { name: "シート部品", quantity: 60, unit_price: 35000 },
      { name: "ドア部品", quantity: 40, unit_price: 45000 }
    ]
  }
]

orders_data.each do |order_data|
  order = Order.find_or_create_by!(
    client: order_data[:client],
    factory_name: order_data[:factory_name],
    order_date: order_data[:order_date]
  ) do |o|
    o.shipping_date = order_data[:shipping_date]
    o.delivery_date = order_data[:delivery_date]
  end

  order_data[:items].each do |item_data|
    order.order_items.find_or_create_by!(name: item_data[:name]) do |item|
      item.quantity = item_data[:quantity]
      item.unit_price = item_data[:unit_price]
    end
  end
end

puts "Created #{Order.count} orders with #{OrderItem.count} order items"
