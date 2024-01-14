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

ActiveRecord::Schema[7.1].define(version: 2024_01_14_015432) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "customers", force: :cascade do |t|
    t.string "cedula", null: false
    t.string "nombres", null: false
    t.string "apellidos", null: false
    t.string "celular", null: false
    t.string "direccion", null: false
    t.string "email", null: false
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

  create_table "licenses", force: :cascade do |t|
    t.string "nombre"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "type_id"
    t.index ["type_id"], name: "index_licenses_on_type_id"
  end

  create_table "procedures", force: :cascade do |t|
    t.string "codigo"
    t.date "fecha"
    t.string "placa"
    t.float "valor"
    t.float "valor_pendiente"
    t.float "ganancia"
    t.float "ganancia_pendiente"
    t.string "observaciones"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.bigint "processor_id"
    t.bigint "customer_id"
    t.bigint "type_id"
    t.bigint "license_id"
    t.bigint "status_id"
    t.index ["customer_id"], name: "index_procedures_on_customer_id"
    t.index ["license_id"], name: "index_procedures_on_license_id"
    t.index ["processor_id"], name: "index_procedures_on_processor_id"
    t.index ["status_id"], name: "index_procedures_on_status_id"
    t.index ["type_id"], name: "index_procedures_on_type_id"
    t.index ["user_id"], name: "index_procedures_on_user_id"
  end

  create_table "processors", force: :cascade do |t|
    t.string "codigo", null: false
    t.string "nombres", null: false
    t.string "apellidos", null: false
    t.string "celular", null: false
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.integer "customers_count", default: 0, null: false
    t.index ["user_id"], name: "index_processors_on_user_id"
  end

  create_table "statuses", force: :cascade do |t|
    t.string "nombre"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "types", force: :cascade do |t|
    t.string "nombre"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "username", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
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
  add_foreign_key "licenses", "types"
  add_foreign_key "procedures", "customers"
  add_foreign_key "procedures", "licenses"
  add_foreign_key "procedures", "processors"
  add_foreign_key "procedures", "statuses"
  add_foreign_key "procedures", "types"
  add_foreign_key "procedures", "users"
  add_foreign_key "processors", "users"
end
