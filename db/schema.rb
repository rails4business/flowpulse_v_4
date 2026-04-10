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

ActiveRecord::Schema[8.1].define(version: 2026_04_09_065729) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "ports", force: :cascade do |t|
    t.bigint "brand_port_id"
    t.string "color_key"
    t.datetime "created_at", null: false
    t.text "description"
    t.jsonb "meta", default: {}
    t.string "name", null: false
    t.integer "port_kind", default: 0, null: false
    t.bigint "profile_id", null: false
    t.datetime "published_at"
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.integer "visibility", default: 0, null: false
    t.integer "x"
    t.integer "y"
    t.index ["brand_port_id"], name: "index_ports_on_brand_port_id"
    t.index ["profile_id", "slug"], name: "index_ports_on_profile_id_and_slug", unique: true
    t.index ["profile_id"], name: "index_ports_on_profile_id"
  end

  create_table "profiles", force: :cascade do |t|
    t.text "bio"
    t.datetime "created_at", null: false
    t.datetime "creator_enabled_until"
    t.datetime "creator_requested_at"
    t.string "display_name", null: false
    t.datetime "professional_enabled_until"
    t.datetime "professional_requested_at"
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.string "visibility", default: "private", null: false
    t.index ["slug"], name: "index_profiles_on_slug", unique: true
    t.index ["user_id"], name: "index_profiles_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.boolean "superadmin", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "ports", "ports", column: "brand_port_id"
  add_foreign_key "ports", "profiles"
  add_foreign_key "profiles", "users"
  add_foreign_key "sessions", "users"
end
