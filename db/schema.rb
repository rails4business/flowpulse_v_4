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

ActiveRecord::Schema[8.1].define(version: 2026_04_11_110000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "brand_domains", force: :cascade do |t|
    t.string "accent_color"
    t.string "background_color"
    t.bigint "brand_port_id", null: false
    t.datetime "created_at", null: false
    t.text "custom_css"
    t.string "favicon_url"
    t.string "header_bg_color"
    t.string "header_text_color"
    t.string "home_page_key"
    t.string "horizontal_logo_url"
    t.string "host", null: false
    t.string "locale", default: "it", null: false
    t.boolean "primary", default: false, null: false
    t.boolean "published", default: false, null: false
    t.text "seo_description"
    t.string "seo_title"
    t.string "square_logo_url"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["brand_port_id", "locale"], name: "index_brand_domains_on_brand_port_id_and_locale", unique: true
    t.index ["brand_port_id", "primary"], name: "index_brand_domains_one_primary_per_brand", unique: true, where: "(\"primary\" = true)"
    t.index ["brand_port_id"], name: "index_brand_domains_on_brand_port_id"
    t.index ["host"], name: "index_brand_domains_on_host", unique: true
  end

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

  create_table "sea_routes", force: :cascade do |t|
    t.boolean "bidirectional", null: false
    t.datetime "created_at", null: false
    t.integer "position", null: false
    t.bigint "profile_id", null: false
    t.bigint "source_port_id", null: false
    t.bigint "target_port_id", null: false
    t.datetime "updated_at", null: false
    t.index ["profile_id", "source_port_id", "target_port_id"], name: "idx_on_profile_id_source_port_id_target_port_id_6682bf4259", unique: true
    t.index ["profile_id"], name: "index_sea_routes_on_profile_id"
    t.index ["source_port_id"], name: "index_sea_routes_on_source_port_id"
    t.index ["target_port_id"], name: "index_sea_routes_on_target_port_id"
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

  add_foreign_key "brand_domains", "ports", column: "brand_port_id"
  add_foreign_key "ports", "ports", column: "brand_port_id"
  add_foreign_key "ports", "profiles"
  add_foreign_key "profiles", "users"
  add_foreign_key "sea_routes", "ports", column: "source_port_id"
  add_foreign_key "sea_routes", "ports", column: "target_port_id"
  add_foreign_key "sea_routes", "profiles"
  add_foreign_key "sessions", "users"
end
