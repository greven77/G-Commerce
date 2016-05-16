# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160515181646) do

  create_table "addresses", force: :cascade do |t|
    t.string   "street",      limit: 255
    t.string   "post_code",   limit: 255
    t.string   "city",        limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "customer_id", limit: 4
    t.integer  "country_id",  limit: 4
  end

  add_index "addresses", ["country_id"], name: "index_addresses_on_country_id", using: :btree
  add_index "addresses", ["customer_id"], name: "index_addresses_on_customer_id", using: :btree

  create_table "categories", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "ancestry",   limit: 255
    t.string   "slug",       limit: 255
  end

  add_index "categories", ["ancestry"], name: "index_categories_on_ancestry", using: :btree
  add_index "categories", ["slug"], name: "index_categories_on_slug", using: :btree

  create_table "countries", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "customers", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.string   "name",       limit: 255
    t.string   "phone",      limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "customers", ["user_id"], name: "index_customers_on_user_id", using: :btree

  create_table "feedbacks", force: :cascade do |t|
    t.text     "comment",     limit: 65535
    t.integer  "rating",      limit: 4
    t.integer  "product_id",  limit: 4
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "customer_id", limit: 4
  end

  add_index "feedbacks", ["customer_id"], name: "index_feedbacks_on_customer_id", using: :btree
  add_index "feedbacks", ["product_id"], name: "index_feedbacks_on_product_id", using: :btree

  create_table "order_statuses", force: :cascade do |t|
    t.string   "description", limit: 255
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.boolean  "default",                 default: false
  end

  create_table "orders", force: :cascade do |t|
    t.integer  "order_status_id", limit: 4
    t.decimal  "total",                     precision: 10
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.integer  "customer_id",     limit: 4
  end

  add_index "orders", ["customer_id"], name: "index_orders_on_customer_id", using: :btree
  add_index "orders", ["order_status_id"], name: "index_orders_on_order_status_id", using: :btree

  create_table "payments", force: :cascade do |t|
    t.string   "card_type",         limit: 255
    t.string   "card_number",       limit: 255
    t.string   "valid_until",       limit: 255
    t.integer  "verification_code", limit: 4
    t.integer  "customer_id",       limit: 4
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "payments", ["customer_id"], name: "index_payments_on_customer_id", using: :btree

  create_table "placements", force: :cascade do |t|
    t.integer  "order_id",   limit: 4
    t.integer  "product_id", limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "quantity",   limit: 4
  end

  add_index "placements", ["order_id"], name: "index_placements_on_order_id", using: :btree
  add_index "placements", ["product_id"], name: "index_placements_on_product_id", using: :btree

  create_table "products", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.string   "product_code", limit: 255
    t.string   "description",  limit: 255
    t.decimal  "price",                    precision: 10
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.integer  "category_id",  limit: 4
    t.string   "image",        limit: 255
  end

  add_index "products", ["category_id"], name: "index_products_on_category_id", using: :btree

  create_table "roles", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "role_id",                limit: 4
    t.string   "authentication_token",   limit: 255
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["role_id"], name: "index_users_on_role_id", using: :btree

  add_foreign_key "addresses", "countries"
  add_foreign_key "addresses", "customers"
  add_foreign_key "customers", "users"
  add_foreign_key "feedbacks", "customers"
  add_foreign_key "feedbacks", "products"
  add_foreign_key "orders", "customers"
  add_foreign_key "orders", "order_statuses"
  add_foreign_key "payments", "customers"
  add_foreign_key "placements", "orders"
  add_foreign_key "placements", "products"
  add_foreign_key "products", "categories"
  add_foreign_key "users", "roles"
end
