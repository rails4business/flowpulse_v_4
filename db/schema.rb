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

ActiveRecord::Schema[8.1].define(version: 2026_04_24_203000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "contents", force: :cascade do |t|
    t.string "banner_url"
    t.text "content"
    t.bigint "contentable_id", null: false
    t.string "contentable_type", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "horizontal_cover_url"
    t.text "mermaid"
    t.jsonb "meta", default: {}, null: false
    t.datetime "published_at"
    t.string "subtitle"
    t.string "thumb_url"
    t.datetime "updated_at", null: false
    t.string "url_media_content"
    t.string "vertical_cover_url"
    t.integer "visibility", default: 0, null: false
    t.index ["contentable_type", "contentable_id"], name: "index_contents_on_contentable"
    t.index ["contentable_type", "contentable_id"], name: "index_contents_on_contentable_type_and_contentable_id", unique: true
    t.index ["meta"], name: "index_contents_on_meta", using: :gin
  end

  create_table "experiences", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "experience_kind", default: 0, null: false
    t.string "name", null: false
    t.bigint "parent_experience_id"
    t.bigint "port_id", null: false
    t.integer "position", default: 0, null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_experience_id"], name: "index_experiences_on_parent_experience_id"
    t.index ["port_id", "position"], name: "index_experiences_on_port_id_and_position"
    t.index ["port_id", "slug"], name: "index_experiences_on_port_id_and_slug", unique: true
    t.index ["port_id"], name: "index_experiences_on_port_id"
  end

  create_table "lines", force: :cascade do |t|
    t.string "color"
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "line_kind", default: 0, null: false
    t.string "name", null: false
    t.bigint "port_id", null: false
    t.integer "position", default: 0, null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["port_id", "position"], name: "index_lines_on_port_id_and_position"
    t.index ["port_id", "slug"], name: "index_lines_on_port_id_and_slug", unique: true
    t.index ["port_id"], name: "index_lines_on_port_id"
  end

  create_table "ports", force: :cascade do |t|
    t.bigint "brand_port_id"
    t.boolean "brand_root", default: false, null: false
    t.string "color_key"
    t.datetime "created_at", null: false
    t.string "entry_value"
    t.jsonb "meta", default: {}
    t.string "name", null: false
    t.integer "port_kind"
    t.bigint "profile_id", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.jsonb "webapp_sea_chart", default: {}, null: false
    t.integer "x"
    t.integer "y"
    t.index ["brand_port_id"], name: "index_ports_on_brand_port_id"
    t.index ["brand_root"], name: "index_ports_on_brand_root"
    t.index ["profile_id", "slug"], name: "index_ports_on_profile_id_and_slug", unique: true
    t.index ["profile_id"], name: "index_ports_on_profile_id"
    t.index ["webapp_sea_chart"], name: "index_ports_on_webapp_sea_chart", using: :gin
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

  create_table "stations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.bigint "experience_id"
    t.bigint "line_id", null: false
    t.integer "link_order", default: 0, null: false
    t.bigint "link_port_id"
    t.bigint "link_station_id"
    t.integer "map_x"
    t.integer "map_y"
    t.string "name", null: false
    t.boolean "port_entry", default: false, null: false
    t.integer "position", default: 0, null: false
    t.integer "shared_group_angle", default: 0, null: false
    t.string "slug", null: false
    t.integer "station_kind", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["experience_id"], name: "index_stations_on_experience_id"
    t.index ["line_id", "position"], name: "index_stations_on_line_id_and_position"
    t.index ["line_id", "slug"], name: "index_stations_on_line_id_and_slug", unique: true
    t.index ["line_id"], name: "index_stations_on_line_id"
    t.index ["link_port_id"], name: "index_stations_on_link_port_id"
    t.index ["link_station_id"], name: "index_stations_on_link_station_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.boolean "superadmin", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  create_table "webapp_domains", force: :cascade do |t|
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
    t.index ["brand_port_id", "locale"], name: "index_webapp_domains_on_brand_port_id_and_locale", unique: true
    t.index ["brand_port_id", "primary"], name: "index_webapp_domains_one_primary_per_brand", unique: true, where: "(\"primary\" = true)"
    t.index ["brand_port_id"], name: "index_webapp_domains_on_brand_port_id"
    t.index ["host"], name: "index_webapp_domains_on_host", unique: true
  end

  add_foreign_key "experiences", "experiences", column: "parent_experience_id"
  add_foreign_key "experiences", "ports"
  add_foreign_key "lines", "ports"
  add_foreign_key "ports", "ports", column: "brand_port_id"
  add_foreign_key "ports", "profiles"
  add_foreign_key "profiles", "users"
  add_foreign_key "sea_routes", "ports", column: "source_port_id"
  add_foreign_key "sea_routes", "ports", column: "target_port_id"
  add_foreign_key "sea_routes", "profiles"
  add_foreign_key "sessions", "users"
  add_foreign_key "stations", "experiences"
  add_foreign_key "stations", "lines"
  add_foreign_key "stations", "ports", column: "link_port_id"
  add_foreign_key "stations", "stations", column: "link_station_id"
  add_foreign_key "webapp_domains", "ports", column: "brand_port_id"
end
