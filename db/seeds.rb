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

# Create 20 orders with varied data
20.times do |i|
  order_number = i + 1
  client_names = [ "アダストリア", "しまむら", "ユニクロ", "ZARA", "H&M" ]
  factory_names = [ "愛知工場", "横浜工場", "埼玉工場", "大阪工場", "福岡工場" ]
  item_names = [ "PO", "SETS", "PK", "BLOUSON", "SHIRT", "PANTS", "SKIRT", "DRESS", "JACKET", "COAT" ]
  trade_terms = [ "FOB", "CIF", "EXW", "DDP" ]

  # Get a random client, or nil for some orders
  client = Client.all.sample

  order = Order.new(
    client: client,
    factory_name: factory_names.sample,
    order_date: Date.current - rand(30).days,
    delivery_date: Date.current + rand(60).days,
    estimate_delivery_date: Date.current + rand(45).days,
    item_number: "O#{rand(10000..99999)}#{('A'..'Z').to_a.sample}#{rand(10..99)}",
    item_name: item_names.sample,
    quantity: rand(50..500),
    trade_term: trade_terms.sample,
    purchase_price: rand(10.0..100.0).round(2),
    sell_price: rand(100..1000),
    exchange_rate: rand(140.0..160.0).round(2),
    sales_multiple: rand(1.2..3.0).round(2),
    export_port: [ "上海", "青島", "天津", "大連" ].sample,
    license: rand < 0.3 ? "License-#{rand(1000..9999)}" : nil,
    status: "draft", # Always start as draft to avoid validation issues
    creator: User.first,
    attachment_urls: rand < 0.4 ? [ "https://example.com/doc#{rand(1..100)}.pdf" ] : []
  )

  # Save without validation for seed data
  order.save(validate: false)

  # Assign random users to some orders
  if rand < 0.6 && User.count > 1
    users_to_assign = User.all.sample(rand(1..2))
    users_to_assign.each do |user|
      order.order_users.create!(user: user)
    end
  end

  puts "Created order #{order_number}: #{order.item_name} for #{client&.name || 'No Client'}"
end

# Create sample files for some orders
require 'tempfile'

orders_with_files = Order.limit(10).order("RANDOM()")
orders_with_files.each_with_index do |order, index|
  # Create 1-3 sample files for each order
  file_count = rand(1..3)

  file_count.times do |file_index|
    # Create a temporary file with sample content
    temp_file = Tempfile.new([ "sample_#{index}_#{file_index}", [ '.pdf', '.doc', '.jpg', '.png' ].sample ])

    case temp_file.path.split('.').last
    when 'pdf'
      temp_file.write("Sample PDF content for order #{order.id}")
    when 'doc'
      temp_file.write("Sample DOC content for order #{order.id}")
    when 'jpg', 'png'
      temp_file.write("Sample image content for order #{order.id}")
    end

    temp_file.rewind

    # Attach the file to the order
    order.files.attach(
      io: temp_file,
      filename: "sample_file_#{order.id}_#{file_index + 1}#{File.extname(temp_file.path)}",
      content_type: case File.extname(temp_file.path)
                    when '.pdf'
                     'application/pdf'
                    when '.doc'
                     'application/msword'
                    when '.jpg'
                     'image/jpeg'
                    when '.png'
                     'image/png'
                    else
                     'application/octet-stream'
                    end
    )

    temp_file.close
    temp_file.unlink
  end

  puts "Attached #{file_count} files to order #{order.id}"
end

puts "Created #{Order.count} orders (#{Order.joins(:files_attachments).distinct.count} with attachments)"

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

# Create common item names for tag suggestions
items_data = [
  { name: "PO", description: "ポロシャツ (Polo Shirt)" },
  { name: "SETS", description: "セット商品 (Set Items)" },
  { name: "PK", description: "パーカー (Parka/Hoodie)" },
  { name: "BLOUSON", description: "ブルゾン (Blouson/Jacket)" },
  { name: "SHIRT", description: "シャツ (Shirt)" },
  { name: "PANTS", description: "パンツ (Pants)" },
  { name: "SKIRT", description: "スカート (Skirt)" },
  { name: "DRESS", description: "ドレス (Dress)" },
  { name: "JACKET", description: "ジャケット (Jacket)" },
  { name: "COAT", description: "コート (Coat)" },
  { name: "SWEATER", description: "セーター (Sweater)" },
  { name: "CARDIGAN", description: "カーディガン (Cardigan)" },
  { name: "BLOUSE", description: "ブラウス (Blouse)" },
  { name: "T-SHIRT", description: "Tシャツ (T-Shirt)" },
  { name: "TANK", description: "タンクトップ (Tank Top)" }
]

items_data.each do |item_data|
  Item.find_or_create_by!(name: item_data[:name]) do |item|
    item.description = item_data[:description]
  end
end

puts "Created #{Item.count} item names for tag suggestions"
