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
  # Try to find a client by name, or use nil if not found
  client = Client.find_by(name: order_data[:client])

  order = Order.find_or_create_by!(
    client: client,
    factory_name: order_data[:factory_name],
    order_date: order_data[:order_date]
  ) do |o|
    o.shipping_date = order_data[:shipping_date]
    o.delivery_date = order_data[:delivery_date]
    o.item_name = order_data[:items].first[:name] if order_data[:items].present?
    o.quantity = order_data[:items].first[:quantity] if order_data[:items].present?
    o.sell_price = order_data[:items].first[:unit_price] if order_data[:items].present?
    o.purchase_price = order_data[:items].first[:unit_price] * 0.7 if order_data[:items].present?
    o.creator_id = User.first.id
  end
end

puts "Created #{Order.count} orders"

# Create Clients with shipping addresses
clients_data = [
  {
    name: "アダストリア",
    address: "〒107-8449 東京都港区南青山3-18-7",
    shipping_addresses: [
      { name: "本社", address: "〒107-8449 東京都港区南青山3-18-7" },
      { name: "グローバルベース", address: "〒300-2793 茨城県常総市蔵持770" },
      { name: "関西営業所", address: "〒542-0081 大阪府大阪市中央区南船場4-4-21" },
      { name: "福岡営業所", address: "〒810-0001 福岡県福岡市中央区天神2-8-38" }
    ]
  },
  {
    name: "しまむら",
    address: "〒330-0843 埼玉県さいたま市大宮区吉敷町4-261-1",
    shipping_addresses: [
      { name: "本社", address: "〒330-0843 埼玉県さいたま市大宮区吉敷町4-261-1" },
      { name: "東日本物流センター", address: "〒306-0313 茨城県猿島郡五霞町元栗橋6990" },
      { name: "西日本物流センター", address: "〒673-1431 兵庫県加東市岡本1588" },
      { name: "九州物流センター", address: "〒841-0204 佐賀県三養基郡基山町宮浦186-12" },
      { name: "北海道物流センター", address: "〒069-1521 北海道夕張郡長沼町西10線北10号" }
    ]
  }
]

clients_data.each do |client_data|
  client = Client.find_or_create_by!(name: client_data[:name]) do |c|
    c.address = client_data[:address]
  end

  # Create shipping addresses for each client
  client_data[:shipping_addresses].each do |shipping_data|
    client.shipping_addresses.find_or_create_by!(name: shipping_data[:name]) do |shipping|
      shipping.address = shipping_data[:address]
    end
  end
end

puts "Created #{Client.count} clients"
puts "Created #{ShippingAddress.count} shipping addresses"
