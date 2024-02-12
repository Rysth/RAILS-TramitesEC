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

ActiveRecord::Schema[7.1].define(version: 2024_02_10_195759) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "customers", force: :cascade do |t|
    t.string "identification", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "phone", null: false
    t.string "email", null: false
    t.string "address", default: ""
    t.boolean "is_direct", default: false
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.bigint "processor_id"
    t.index ["processor_id"], name: "index_customers_on_processor_id"
    t.index ["user_id"], name: "index_customers_on_user_id"
  end

  create_table "devise_api_tokens", force: :cascade do |t|
    t.string "resource_owner_type", null: false
    t.bigint "resource_owner_id", null: false
    t.string "access_token", null: false
    t.string "refresh_token"
    t.integer "expires_in", null: false
    t.datetime "revoked_at"
    t.string "previous_refresh_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["access_token"], name: "index_devise_api_tokens_on_access_token"
    t.index ["previous_refresh_token"], name: "index_devise_api_tokens_on_previous_refresh_token"
    t.index ["refresh_token"], name: "index_devise_api_tokens_on_refresh_token"
    t.index ["resource_owner_type", "resource_owner_id"], name: "index_devise_api_tokens_on_resource_owner"
  end

  create_table "license_types", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_license_types_on_name", unique: true
  end

  create_table "licenses", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "active", default: true
    t.bigint "license_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["license_type_id"], name: "index_licenses_on_license_type_id"
  end

  create_table "payment_types", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "payments", force: :cascade do |t|
    t.date "date", null: false
    t.float "value", null: false
    t.string "receipt_number"
    t.bigint "payment_type_id", null: false
    t.bigint "procedure_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["payment_type_id"], name: "index_payments_on_payment_type_id"
    t.index ["procedure_id"], name: "index_payments_on_procedure_id"
  end

  create_table "procedure_types", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "active", default: true
    t.boolean "has_children", default: false
    t.boolean "has_licenses", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_procedure_types_on_name", unique: true
  end

  create_table "procedures", force: :cascade do |t|
    t.string "code", null: false
    t.date "date", null: false
    t.string "plate"
    t.float "cost", null: false
    t.float "cost_pending", null: false
    t.float "profit", null: false
    t.float "profit_pending", null: false
    t.text "comments"
    t.boolean "is_paid", default: false, null: false
    t.boolean "active", default: true, null: false
    t.bigint "user_id", null: false
    t.bigint "processor_id"
    t.bigint "customer_id", null: false
    t.bigint "procedure_type_id", null: false
    t.bigint "status_id", null: false
    t.bigint "license_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_procedures_on_customer_id"
    t.index ["license_id"], name: "index_procedures_on_license_id"
    t.index ["procedure_type_id"], name: "index_procedures_on_procedure_type_id"
    t.index ["processor_id"], name: "index_procedures_on_processor_id"
    t.index ["status_id"], name: "index_procedures_on_status_id"
    t.index ["user_id"], name: "index_procedures_on_user_id"
  end

  create_table "processors", force: :cascade do |t|
    t.string "code", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "phone", null: false
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.integer "customers_count", default: 0, null: false
    t.index ["user_id"], name: "index_processors_on_user_id"
  end

  create_table "statuses", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_statuses_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "username", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.boolean "is_admin", default: false, null: false
    t.boolean "active", default: true, null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "customers", "processors"
  add_foreign_key "customers", "users"
  add_foreign_key "licenses", "license_types"
  add_foreign_key "payments", "payment_types"
  add_foreign_key "payments", "procedures"
  add_foreign_key "procedures", "customers"
  add_foreign_key "procedures", "licenses"
  add_foreign_key "procedures", "procedure_types"
  add_foreign_key "procedures", "processors"
  add_foreign_key "procedures", "statuses"
  add_foreign_key "procedures", "users"
  add_foreign_key "processors", "users"
end
