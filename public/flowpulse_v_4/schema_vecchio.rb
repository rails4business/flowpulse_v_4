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

ActiveRecord::Schema[8.1].define(version: 2026_03_25_084030) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "activities", force: :cascade do |t|
    t.bigint "booking_id"
    t.integer "center_taxbranch_id"
    t.bigint "certificate_id"
    t.string "channel"
    t.datetime "created_at", null: false
    t.bigint "domain_id"
    t.bigint "enrollment_id"
    t.bigint "eventdate_id"
    t.string "format"
    t.integer "group_size"
    t.string "kind", null: false
    t.bigint "lead_id", null: false
    t.string "level_code"
    t.text "location_address"
    t.string "location_name"
    t.string "location_type"
    t.string "mode"
    t.datetime "occurred_at", null: false
    t.jsonb "payload", default: {}, null: false
    t.integer "score_max"
    t.integer "score_total"
    t.bigint "service_id"
    t.string "source"
    t.string "source_ref"
    t.string "status", default: "recorded", null: false
    t.bigint "taxbranch_id"
    t.datetime "updated_at", null: false
    t.index ["booking_id"], name: "index_activities_on_booking_id"
    t.index ["center_taxbranch_id"], name: "index_activities_on_center_taxbranch_id"
    t.index ["certificate_id"], name: "index_activities_on_certificate_id"
    t.index ["channel"], name: "index_activities_on_channel"
    t.index ["domain_id", "occurred_at"], name: "index_activities_on_domain_id_and_occurred_at"
    t.index ["domain_id"], name: "index_activities_on_domain_id"
    t.index ["enrollment_id"], name: "index_activities_on_enrollment_id"
    t.index ["eventdate_id"], name: "index_activities_on_eventdate_id"
    t.index ["format"], name: "index_activities_on_format"
    t.index ["kind", "occurred_at"], name: "index_activities_on_kind_and_occurred_at"
    t.index ["lead_id", "occurred_at"], name: "index_activities_on_lead_id_and_occurred_at"
    t.index ["lead_id", "taxbranch_id"], name: "index_activities_unique_open_per_lead_taxbranch", unique: true, where: "((status)::text = ANY ((ARRAY['recorded'::character varying, 'reviewed'::character varying])::text[]))"
    t.index ["lead_id"], name: "index_activities_on_lead_id"
    t.index ["level_code"], name: "index_activities_on_level_code"
    t.index ["location_type"], name: "index_activities_on_location_type"
    t.index ["mode"], name: "index_activities_on_mode"
    t.index ["service_id"], name: "index_activities_on_service_id"
    t.index ["taxbranch_id"], name: "index_activities_on_taxbranch_id"
  end

  create_table "book_domains", force: :cascade do |t|
    t.bigint "book_id", null: false
    t.datetime "created_at", null: false
    t.bigint "domain_id", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_book_domains_on_book_id"
    t.index ["domain_id"], name: "index_book_domains_on_domain_id"
  end

  create_table "bookings", force: :cascade do |t|
    t.bigint "commitment_id"
    t.datetime "created_at", null: false
    t.bigint "enrollment_id"
    t.bigint "eventdate_id", null: false
    t.bigint "invited_by_lead_id"
    t.string "journey_role"
    t.jsonb "meta", default: {}
    t.integer "mode", default: 0, null: false
    t.bigint "mycontact_id", null: false
    t.text "notes"
    t.integer "participant_role", default: 0, null: false
    t.decimal "price_dash", precision: 16, scale: 8
    t.decimal "price_euro", precision: 10, scale: 2
    t.bigint "requested_by_lead_id"
    t.bigint "service_id"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["commitment_id"], name: "index_bookings_on_commitment_id"
    t.index ["enrollment_id"], name: "index_bookings_on_enrollment_id"
    t.index ["eventdate_id"], name: "index_bookings_on_eventdate_id"
    t.index ["invited_by_lead_id"], name: "index_bookings_on_invited_by_lead_id"
    t.index ["mycontact_id"], name: "index_bookings_on_mycontact_id"
    t.index ["requested_by_lead_id"], name: "index_bookings_on_requested_by_lead_id"
    t.index ["service_id"], name: "index_bookings_on_service_id"
  end

  create_table "books", force: :cascade do |t|
    t.integer "access_mode"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "folder_md"
    t.string "index_file"
    t.decimal "price_dash", precision: 10, scale: 2
    t.decimal "price_euro", precision: 10, scale: 2
    t.string "slug"
    t.string "title"
    t.datetime "updated_at", null: false
  end

  create_table "certificates", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "datacontact_id", null: false
    t.bigint "domain_id"
    t.bigint "domain_membership_id", null: false
    t.bigint "enrollment_id", null: false
    t.datetime "expires_at"
    t.datetime "issued_at"
    t.integer "issued_by_enrollment_id"
    t.bigint "journey_id", null: false
    t.bigint "lead_id", null: false
    t.jsonb "meta"
    t.string "role_name"
    t.bigint "service_id", null: false
    t.integer "status"
    t.bigint "taxbranch_id", null: false
    t.datetime "updated_at", null: false
    t.index ["datacontact_id"], name: "index_certificates_on_datacontact_id"
    t.index ["domain_id"], name: "index_certificates_on_domain_id"
    t.index ["domain_membership_id", "role_name"], name: "index_certificates_on_domain_membership_id_and_role_name"
    t.index ["domain_membership_id"], name: "index_certificates_on_domain_membership_id"
    t.index ["enrollment_id"], name: "index_certificates_on_enrollment_id"
    t.index ["journey_id"], name: "index_certificates_on_journey_id"
    t.index ["lead_id"], name: "index_certificates_on_lead_id"
    t.index ["service_id"], name: "index_certificates_on_service_id"
    t.index ["taxbranch_id"], name: "index_certificates_on_taxbranch_id"
  end

  create_table "commitments", force: :cascade do |t|
    t.string "area"
    t.integer "commitment_kind", default: 0, null: false
    t.decimal "compensation_dash", precision: 16, scale: 8
    t.decimal "compensation_euro", precision: 8, scale: 2
    t.datetime "created_at", null: false
    t.integer "duration_minutes"
    t.integer "energy"
    t.bigint "eventdate_id", null: false
    t.integer "importance"
    t.jsonb "meta", default: {}, null: false
    t.text "notes"
    t.integer "position"
    t.integer "role_count"
    t.string "role_name"
    t.bigint "taxbranch_id"
    t.bigint "template_commitment_id"
    t.datetime "updated_at", null: false
    t.integer "urgency"
    t.index ["eventdate_id"], name: "index_commitments_on_eventdate_id"
    t.index ["template_commitment_id"], name: "index_commitments_on_template_commitment_id"
  end

  create_table "datacontacts", force: :cascade do |t|
    t.string "billing_address"
    t.string "billing_city"
    t.string "billing_country"
    t.string "billing_name"
    t.string "billing_zip"
    t.datetime "created_at", null: false
    t.date "date_of_birth"
    t.string "email"
    t.string "first_name"
    t.string "fiscal_code"
    t.string "last_name"
    t.bigint "lead_id"
    t.jsonb "meta"
    t.string "phone"
    t.string "place_of_birth"
    t.integer "referent_lead_id"
    t.text "socials"
    t.datetime "updated_at", null: false
    t.string "vat_number"
    t.index ["lead_id"], name: "index_datacontacts_on_lead_id"
  end

  create_table "domain_memberships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "domain_active_role", default: "member", null: false
    t.bigint "domain_id", null: false
    t.bigint "lead_id", null: false
    t.boolean "primary", default: false, null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["domain_id"], name: "index_domain_memberships_on_domain_id"
    t.index ["lead_id", "domain_id"], name: "idx_domain_memberships_lead_domain_unique", unique: true
    t.index ["lead_id"], name: "idx_domain_memberships_primary_per_lead", unique: true, where: "(\"primary\" = true)"
    t.index ["lead_id"], name: "index_domain_memberships_on_lead_id"
  end

  create_table "domains", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "favicon_url"
    t.string "horizontal_logo_url"
    t.string "host"
    t.string "language"
    t.jsonb "operative_roles", default: []
    t.string "provider"
    t.string "square_logo_url"
    t.bigint "taxbranch_id", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["host"], name: "index_domains_on_host", unique: true
    t.index ["taxbranch_id"], name: "index_domains_on_taxbranch_id"
  end

  create_table "enrollments", force: :cascade do |t|
    t.datetime "certified_at"
    t.datetime "created_at", null: false
    t.bigint "invited_by_lead_id"
    t.bigint "journey_id"
    t.string "journey_role"
    t.jsonb "meta", default: {}
    t.integer "mode", default: 0, null: false
    t.bigint "mycontact_id", null: false
    t.text "notes"
    t.string "participant_role"
    t.integer "phase", default: 0, null: false
    t.decimal "price_dash", precision: 16, scale: 8
    t.decimal "price_euro", precision: 10, scale: 2
    t.integer "request_kind", default: 0, null: false
    t.bigint "requested_by_lead_id"
    t.string "role_name"
    t.bigint "service_id"
    t.integer "status", default: 0, null: false
    t.string "target_role"
    t.datetime "updated_at", null: false
    t.index ["invited_by_lead_id"], name: "index_enrollments_on_invited_by_lead_id"
    t.index ["journey_id"], name: "index_enrollments_on_journey_id"
    t.index ["mycontact_id"], name: "index_enrollments_on_mycontact_id"
    t.index ["requested_by_lead_id"], name: "index_enrollments_on_requested_by_lead_id"
    t.index ["service_id"], name: "index_enrollments_on_service_id"
  end

  create_table "eventdates", force: :cascade do |t|
    t.boolean "allows_invite"
    t.boolean "allows_request"
    t.bigint "child_journey_id"
    t.datetime "created_at", null: false
    t.datetime "date_end"
    t.datetime "date_start"
    t.text "description"
    t.bigint "domain_id", null: false
    t.bigint "domain_membership_id", null: false
    t.integer "event_type", default: 0, null: false
    t.bigint "journey_id"
    t.string "journey_role"
    t.integer "kind_event", default: 0, null: false
    t.bigint "lead_id", null: false
    t.string "location"
    t.integer "max_participants"
    t.jsonb "meta"
    t.integer "mode", default: 0, null: false
    t.bigint "parent_eventdate_id"
    t.integer "position"
    t.integer "status"
    t.bigint "taxbranch_id"
    t.integer "time_duration"
    t.integer "unit_duration"
    t.datetime "updated_at", null: false
    t.integer "visibility", default: 0, null: false
    t.index ["child_journey_id"], name: "index_eventdates_on_child_journey_id"
    t.index ["domain_id"], name: "index_eventdates_on_domain_id"
    t.index ["domain_membership_id"], name: "index_eventdates_on_domain_membership_id"
    t.index ["journey_id"], name: "index_eventdates_on_journey_id"
    t.index ["lead_id"], name: "index_eventdates_on_lead_id"
    t.index ["parent_eventdate_id"], name: "index_eventdates_on_parent_eventdate_id"
    t.index ["taxbranch_id"], name: "index_eventdates_on_taxbranch_id"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.datetime "created_at"
    t.string "scope"
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "journeys", force: :cascade do |t|
    t.boolean "allows_invite"
    t.boolean "allows_request"
    t.datetime "created_at", null: false
    t.datetime "end_at"
    t.integer "end_taxbranch_id"
    t.integer "energy"
    t.integer "importance"
    t.jsonb "journey_roles", default: [], null: false
    t.integer "journey_type", default: 0
    t.integer "journeys_status", default: 0, null: false
    t.integer "kind", default: 0, null: false
    t.bigint "lead_id", null: false
    t.jsonb "meta", default: {}, null: false
    t.string "mode"
    t.text "notes"
    t.string "phase"
    t.decimal "price_estimate_dash", precision: 16, scale: 8
    t.decimal "price_estimate_euro", precision: 8, scale: 2
    t.integer "progress"
    t.bigint "service_id"
    t.string "slug"
    t.datetime "start_at"
    t.bigint "taxbranch_id"
    t.bigint "template_journey_id"
    t.string "title"
    t.datetime "updated_at", null: false
    t.integer "urgency"
    t.index ["end_taxbranch_id"], name: "index_journeys_on_end_taxbranch_id"
    t.index ["lead_id"], name: "index_journeys_on_lead_id"
    t.index ["service_id"], name: "index_journeys_on_service_id"
    t.index ["slug"], name: "index_journeys_on_slug", unique: true
    t.index ["taxbranch_id"], name: "index_journeys_on_taxbranch_id"
    t.index ["template_journey_id"], name: "index_journeys_on_template_journey_id"
  end

  create_table "leads", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.jsonb "meta", default: {}
    t.string "name"
    t.integer "parent_id"
    t.string "phone"
    t.integer "referral_lead_id"
    t.string "surname"
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.string "username", null: false
    t.index ["email"], name: "index_leads_on_email"
    t.index ["parent_id"], name: "index_leads_on_parent_id"
    t.index ["referral_lead_id"], name: "index_leads_on_referral_lead_id"
    t.index ["token"], name: "index_leads_on_token", unique: true
    t.index ["username"], name: "index_leads_on_username", unique: true
  end

  create_table "mycontacts", force: :cascade do |t|
    t.datetime "approved_by_referent_at"
    t.datetime "created_at", null: false
    t.bigint "datacontact_id", null: false
    t.bigint "lead_id", null: false
    t.boolean "original"
    t.string "status_contact"
    t.datetime "updated_at", null: false
    t.index ["datacontact_id"], name: "index_mycontacts_on_datacontact_id"
    t.index ["lead_id"], name: "index_mycontacts_on_lead_id"
  end

  create_table "payments", force: :cascade do |t|
    t.decimal "amount_dash", precision: 16, scale: 8
    t.decimal "amount_euro", precision: 10, scale: 2
    t.bigint "contact_id", null: false
    t.datetime "created_at", null: false
    t.string "currency", default: "EUR"
    t.string "external_id"
    t.integer "kind", default: 0, null: false
    t.jsonb "meta", default: {}
    t.integer "method", default: 0, null: false
    t.text "notes"
    t.datetime "paid_at"
    t.bigint "parent_payment_id"
    t.bigint "payable_id", null: false
    t.string "payable_type", null: false
    t.decimal "refund_amount_euro", precision: 10, scale: 2
    t.datetime "refund_due_at"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["contact_id"], name: "index_payments_on_contact_id"
    t.index ["parent_payment_id"], name: "index_payments_on_parent_payment_id"
    t.index ["payable_type", "payable_id"], name: "index_payments_on_payable"
  end

  create_table "posts", force: :cascade do |t|
    t.string "banner_url"
    t.text "content"
    t.text "content_md"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "horizontal_cover_url"
    t.bigint "lead_id", null: false
    t.text "mermaid"
    t.jsonb "meta", default: {}
    t.string "slug"
    t.integer "taxbranch_id"
    t.string "thumb_url"
    t.string "title"
    t.datetime "updated_at", null: false
    t.string "url_media_content"
    t.string "vertical_cover_url"
    t.index ["lead_id"], name: "index_posts_on_lead_id"
    t.index ["meta"], name: "index_posts_on_meta", using: :gin
    t.index ["slug"], name: "index_posts_on_slug", unique: true
    t.index ["taxbranch_id"], name: "index_posts_on_taxbranch_id", unique: true
  end

  create_table "services", force: :cascade do |t|
    t.jsonb "allowed_roles", default: [], null: false
    t.boolean "allows_invite", default: true, null: false
    t.boolean "allows_request", default: true, null: false
    t.boolean "auto_certificate"
    t.jsonb "builders_roles", default: [], null: false
    t.text "content_md"
    t.datetime "created_at", null: false
    t.text "description"
    t.jsonb "drivers_roles", default: [], null: false
    t.integer "enrollable_from_phase"
    t.integer "enrollable_until_phase"
    t.string "image_url"
    t.integer "included_in_service_id"
    t.bigint "lead_id", null: false
    t.integer "max_tickets"
    t.jsonb "meta", default: {}, null: false
    t.integer "min_tickets"
    t.integer "n_eventdates_planned"
    t.string "name"
    t.boolean "open_by_journey"
    t.jsonb "output_roles", default: [], null: false
    t.decimal "price_enrollment_euro", precision: 8, scale: 2
    t.decimal "price_ticket_dash", precision: 16, scale: 8
    t.boolean "require_booking_verification"
    t.boolean "require_enrollment_verification"
    t.integer "service_phase"
    t.string "slug"
    t.bigint "taxbranch_id", null: false
    t.datetime "updated_at", null: false
    t.jsonb "verifier_roles"
    t.index ["lead_id"], name: "index_services_on_lead_id"
    t.index ["slug"], name: "index_services_on_slug", unique: true
    t.index ["taxbranch_id"], name: "index_services_on_taxbranch_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "slot_instances", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "date_end"
    t.datetime "date_start"
    t.text "notes"
    t.bigint "slot_template_id", null: false
    t.integer "status"
    t.datetime "updated_at", null: false
    t.index ["slot_template_id"], name: "index_slot_instances_on_slot_template_id"
  end

  create_table "slot_templates", force: :cascade do |t|
    t.string "color_hex"
    t.datetime "created_at", null: false
    t.integer "day_of_week"
    t.text "description"
    t.string "jsonb"
    t.bigint "lead_id", null: false
    t.date "repeat_end"
    t.integer "repeat_every"
    t.integer "repeat_rule"
    t.date "repeat_start"
    t.string "seasons"
    t.bigint "taxbranch_id"
    t.time "time_end"
    t.time "time_start"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["lead_id"], name: "index_slot_templates_on_lead_id"
    t.index ["taxbranch_id"], name: "index_slot_templates_on_taxbranch_id"
  end

  create_table "tag_positionings", force: :cascade do |t|
    t.string "category", null: false
    t.datetime "created_at", null: false
    t.bigint "lead_id", null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "name", null: false
    t.bigint "taxbranch_id", null: false
    t.datetime "updated_at", null: false
    t.index ["lead_id"], name: "index_tag_positionings_on_lead_id"
    t.index ["metadata"], name: "index_tag_positionings_on_metadata", using: :gin
    t.index ["taxbranch_id", "category", "name"], name: "index_tag_positionings_on_taxbranch_id_and_category_and_name", unique: true
    t.index ["taxbranch_id", "category"], name: "index_tag_positionings_on_taxbranch_id_and_category"
    t.index ["taxbranch_id"], name: "index_tag_positionings_on_taxbranch_id"
  end

  create_table "taxbranches", force: :cascade do |t|
    t.string "address_privacy", default: "private", null: false
    t.string "ancestry"
    t.datetime "created_at", null: false
    t.string "execution_mode", default: "both", null: false
    t.text "generaimpresa_md"
    t.boolean "home_nav"
    t.bigint "lead_id", null: false
    t.bigint "link_child_taxbranch_id"
    t.jsonb "meta"
    t.string "notes"
    t.boolean "order_des", default: false
    t.jsonb "performed_by_roles", default: [], null: false
    t.jsonb "permission_access_roles", default: [], null: false
    t.integer "phase", default: 0, null: false
    t.integer "position"
    t.boolean "positioning_tag_public", default: false, null: false
    t.text "private_address"
    t.text "public_address"
    t.datetime "published_at"
    t.jsonb "questionnaire_config"
    t.integer "scheduled_eventdate_id"
    t.boolean "service_certificable"
    t.string "slug", null: false
    t.string "slug_category"
    t.string "slug_label"
    t.integer "status", default: 0, null: false
    t.jsonb "target_roles", default: [], null: false
    t.datetime "updated_at", null: false
    t.integer "visibility", default: 0, null: false
    t.integer "x_coordinated"
    t.integer "y_coordinated"
    t.index ["address_privacy"], name: "index_taxbranches_on_address_privacy"
    t.index ["execution_mode"], name: "index_taxbranches_on_execution_mode"
    t.index ["lead_id"], name: "index_taxbranches_on_lead_id"
    t.index ["link_child_taxbranch_id"], name: "index_taxbranches_on_link_child_taxbranch_id"
    t.index ["performed_by_roles"], name: "index_taxbranches_on_performed_by_roles", using: :gin
    t.index ["positioning_tag_public"], name: "index_taxbranches_on_positioning_tag_public"
    t.index ["scheduled_eventdate_id"], name: "index_taxbranches_on_scheduled_eventdate_id"
    t.index ["slug"], name: "index_taxbranches_on_slug", unique: true
    t.index ["slug_category", "slug_label", "slug"], name: "index_taxbranches_on_cat_label_slug_unique", unique: true
    t.index ["target_roles"], name: "index_taxbranches_on_target_roles", using: :gin
  end

  create_table "users", force: :cascade do |t|
    t.integer "active_certificate_id"
    t.datetime "approved_at"
    t.bigint "approved_by_lead_id"
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.integer "invites_count", default: 0, null: false
    t.integer "invites_limit", default: 7, null: false
    t.datetime "last_active_at"
    t.bigint "lead_id"
    t.string "password_digest", null: false
    t.integer "referrer_id"
    t.integer "state_registration", default: 0, null: false
    t.boolean "superadmin", default: false, null: false
    t.boolean "superadmin_mode_active", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["active_certificate_id"], name: "index_users_on_active_certificate_id"
    t.index ["approved_by_lead_id"], name: "index_users_on_approved_by_lead_id"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["lead_id"], name: "index_users_on_lead_id"
    t.index ["referrer_id"], name: "index_users_on_referrer_id"
    t.index ["state_registration"], name: "index_users_on_state_registration"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "activities", "bookings"
  add_foreign_key "activities", "certificates"
  add_foreign_key "activities", "domains"
  add_foreign_key "activities", "enrollments"
  add_foreign_key "activities", "eventdates"
  add_foreign_key "activities", "leads"
  add_foreign_key "activities", "services"
  add_foreign_key "activities", "taxbranches"
  add_foreign_key "activities", "taxbranches", column: "center_taxbranch_id"
  add_foreign_key "book_domains", "books"
  add_foreign_key "book_domains", "domains"
  add_foreign_key "bookings", "commitments"
  add_foreign_key "bookings", "datacontacts", column: "mycontact_id"
  add_foreign_key "bookings", "enrollments"
  add_foreign_key "bookings", "eventdates"
  add_foreign_key "bookings", "leads", column: "invited_by_lead_id"
  add_foreign_key "bookings", "leads", column: "requested_by_lead_id"
  add_foreign_key "bookings", "services"
  add_foreign_key "certificates", "datacontacts"
  add_foreign_key "certificates", "domain_memberships"
  add_foreign_key "certificates", "domains"
  add_foreign_key "certificates", "enrollments"
  add_foreign_key "certificates", "enrollments", column: "issued_by_enrollment_id"
  add_foreign_key "certificates", "journeys"
  add_foreign_key "certificates", "leads"
  add_foreign_key "certificates", "services"
  add_foreign_key "certificates", "taxbranches"
  add_foreign_key "commitments", "commitments", column: "template_commitment_id"
  add_foreign_key "commitments", "eventdates"
  add_foreign_key "datacontacts", "leads"
  add_foreign_key "domain_memberships", "domains"
  add_foreign_key "domain_memberships", "leads"
  add_foreign_key "domains", "taxbranches"
  add_foreign_key "enrollments", "datacontacts", column: "mycontact_id"
  add_foreign_key "enrollments", "journeys"
  add_foreign_key "enrollments", "leads", column: "invited_by_lead_id"
  add_foreign_key "enrollments", "leads", column: "requested_by_lead_id"
  add_foreign_key "enrollments", "services"
  add_foreign_key "eventdates", "domain_memberships"
  add_foreign_key "eventdates", "domains"
  add_foreign_key "eventdates", "eventdates", column: "parent_eventdate_id"
  add_foreign_key "eventdates", "journeys"
  add_foreign_key "eventdates", "journeys", column: "child_journey_id"
  add_foreign_key "eventdates", "leads"
  add_foreign_key "eventdates", "taxbranches"
  add_foreign_key "journeys", "journeys", column: "template_journey_id"
  add_foreign_key "journeys", "leads"
  add_foreign_key "journeys", "services"
  add_foreign_key "journeys", "taxbranches"
  add_foreign_key "mycontacts", "datacontacts"
  add_foreign_key "mycontacts", "leads"
  add_foreign_key "payments", "datacontacts", column: "contact_id"
  add_foreign_key "payments", "payments", column: "parent_payment_id"
  add_foreign_key "posts", "leads"
  add_foreign_key "services", "leads"
  add_foreign_key "services", "services", column: "included_in_service_id"
  add_foreign_key "services", "taxbranches"
  add_foreign_key "sessions", "users"
  add_foreign_key "slot_instances", "slot_templates"
  add_foreign_key "slot_templates", "leads"
  add_foreign_key "slot_templates", "taxbranches"
  add_foreign_key "tag_positionings", "leads"
  add_foreign_key "tag_positionings", "taxbranches"
  add_foreign_key "taxbranches", "leads"
  add_foreign_key "taxbranches", "taxbranches", column: "link_child_taxbranch_id"
  add_foreign_key "users", "certificates", column: "active_certificate_id"
  add_foreign_key "users", "leads"
  add_foreign_key "users", "leads", column: "approved_by_lead_id"
end
