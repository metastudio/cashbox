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

ActiveRecord::Schema.define(version: 20150326151547) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "bank_accounts", force: true do |t|
    t.string   "name",                                      null: false
    t.string   "description"
    t.integer  "balance_cents",   limit: 8, default: 0,     null: false
    t.string   "currency",                  default: "USD", null: false
    t.integer  "organization_id",                           null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.boolean  "visible",                   default: true
    t.integer  "position"
  end

  add_index "bank_accounts", ["deleted_at"], name: "index_bank_accounts_on_deleted_at", using: :btree
  add_index "bank_accounts", ["organization_id"], name: "index_bank_accounts_on_organization_id", using: :btree

  create_table "categories", force: true do |t|
    t.string   "type",                            null: false
    t.string   "name",                            null: false
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "system",          default: false
    t.datetime "deleted_at"
  end

  add_index "categories", ["deleted_at"], name: "index_categories_on_deleted_at", using: :btree
  add_index "categories", ["organization_id"], name: "index_categories_on_organization_id", using: :btree

  create_table "customers", force: true do |t|
    t.string   "name",            null: false
    t.integer  "organization_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "customers", ["deleted_at"], name: "index_customers_on_deleted_at", using: :btree
  add_index "customers", ["name", "organization_id"], name: "index_customers_on_name_and_organization_id", unique: true, using: :btree
  add_index "customers", ["organization_id"], name: "index_customers_on_organization_id", using: :btree

  create_table "exchange_rates", force: true do |t|
    t.hstore   "rates",                null: false
    t.datetime "updated_from_bank_at", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "members", force: true do |t|
    t.integer  "user_id",         null: false
    t.integer  "organization_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "role",            null: false
  end

  add_index "members", ["user_id", "organization_id"], name: "index_members_on_user_id_and_organization_id", unique: true, using: :btree

  create_table "organizations", force: true do |t|
    t.string   "name",                             null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "default_currency", default: "USD"
  end

  create_table "profiles", force: true do |t|
    t.integer  "user_id",      null: false
    t.string   "position"
    t.string   "avatar"
    t.string   "phone_number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "profiles", ["user_id"], name: "index_profiles_on_user_id", unique: true, using: :btree

  create_table "transactions", force: true do |t|
    t.integer  "amount_cents",     limit: 8, default: 0, null: false
    t.integer  "category_id"
    t.integer  "bank_account_id",                        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "comment"
    t.string   "transaction_type"
    t.datetime "deleted_at"
    t.integer  "customer_id"
  end

  add_index "transactions", ["bank_account_id"], name: "index_transactions_on_bank_account_id", using: :btree
  add_index "transactions", ["category_id"], name: "index_transactions_on_category_id", using: :btree
  add_index "transactions", ["customer_id"], name: "index_transactions_on_customer_id", using: :btree
  add_index "transactions", ["deleted_at"], name: "index_transactions_on_deleted_at", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "failed_attempts",        default: 0,  null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "full_name",                           null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree

end
