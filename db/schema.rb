# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_07_30_023103) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index [ "blob_id" ], name: "index_active_storage_attachments_on_blob_id"
    t.index [ "record_type", "record_id", "name", "blob_id" ], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index [ "key" ], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index [ "blob_id", "variation_digest" ], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "chat_messages", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "user_id", null: false
    t.text "content", null: false
    t.text "mentioned_users"
    t.boolean "is_system_message", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index [ "order_id", "created_at" ], name: "index_chat_messages_on_order_id_and_created_at"
    t.index [ "order_id" ], name: "index_chat_messages_on_order_id"
    t.index [ "user_id" ], name: "index_chat_messages_on_user_id"
  end

  create_table "clients", force: :cascade do |t|
    t.string "name"
    t.text "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "items", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index [ "name" ], name: "index_items_on_name", unique: true
  end

  create_table "order_users", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index [ "order_id", "user_id" ], name: "index_order_users_on_order_id_and_user_id", unique: true
    t.index [ "order_id" ], name: "index_order_users_on_order_id"
    t.index [ "user_id" ], name: "index_order_users_on_user_id"
  end

  create_table "orders", force: :cascade do |t|
    t.string "client"
    t.string "factory_name"
    t.date "order_date"
    t.date "delivery_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "creator_id", null: false
    t.text "attachment_urls", default: [], array: true
    t.jsonb "file_metadata", default: {}
    t.string "item_number"
    t.string "item_name"
    t.integer "quantity"
    t.string "trade_term"
    t.decimal "purchase_price", precision: 10, scale: 2
    t.integer "sell_price"
    t.string "export_port"
    t.date "estimate_delivery_date"
    t.decimal "sales_multiple", precision: 10, scale: 4
    t.integer "exchange_rate"
    t.string "license"
    t.bigint "client_id"
    t.string "status", default: "draft", null: false
    t.bigint "shipping_address_id"
    t.index [ "client_id" ], name: "index_orders_on_client_id"
    t.index [ "creator_id" ], name: "index_orders_on_creator_id"
    t.index [ "shipping_address_id" ], name: "index_orders_on_shipping_address_id"
    t.index [ "status" ], name: "index_orders_on_status"
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index [ "user_id" ], name: "index_sessions_on_user_id"
  end

  create_table "shipping_addresses", force: :cascade do |t|
    t.bigint "client_id", null: false
    t.text "address"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index [ "client_id" ], name: "index_shipping_addresses_on_client_id"
  end

  create_table "user_invitations", force: :cascade do |t|
    t.string "email_address", null: false
    t.bigint "invited_by_id", null: false
    t.datetime "invited_at", null: false
    t.datetime "accepted_at"
    t.string "token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "cancelled_at"
    t.index [ "email_address" ], name: "index_user_invitations_on_email_address", unique: true
    t.index [ "invited_by_id" ], name: "index_user_invitations_on_invited_by_id"
    t.index [ "token" ], name: "index_user_invitations_on_token", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "family_name_eng", null: false
    t.string "given_name_eng", null: false
    t.string "family_name_kanji", null: false
    t.string "given_name_kanji", null: false
    t.index [ "email_address" ], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "chat_messages", "orders"
  add_foreign_key "chat_messages", "users"
  add_foreign_key "order_users", "orders"
  add_foreign_key "order_users", "users"
  add_foreign_key "orders", "clients"
  add_foreign_key "orders", "shipping_addresses"
  add_foreign_key "orders", "users", column: "creator_id"
  add_foreign_key "sessions", "users"
  add_foreign_key "shipping_addresses", "clients"
  add_foreign_key "user_invitations", "users", column: "invited_by_id"
end
