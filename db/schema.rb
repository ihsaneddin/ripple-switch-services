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

ActiveRecord::Schema.define(version: 20180105081816) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"
  enable_extension "pgcrypto"

  create_table "administration_admins", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "username"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "token"
    t.string "encrypted_pin"
    t.string "encrypted_pin_iv"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_administration_admins_on_confirmation_token", unique: true
    t.index ["deleted_at"], name: "index_administration_admins_on_deleted_at"
    t.index ["email"], name: "index_administration_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_administration_admins_on_reset_password_token", unique: true
    t.index ["token"], name: "index_administration_admins_on_token", unique: true
    t.index ["unlock_token"], name: "index_administration_admins_on_unlock_token", unique: true
    t.index ["username"], name: "index_administration_admins_on_username", unique: true
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"
  end

  create_table "oauth_access_grants", force: :cascade do |t|
    t.integer "resource_owner_id", null: false
    t.bigint "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.string "scopes"
    t.index ["application_id"], name: "index_oauth_access_grants_on_application_id"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.integer "resource_owner_id"
    t.bigint "application_id"
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.string "scopes"
    t.string "previous_refresh_token", default: "", null: false
    t.index ["application_id"], name: "index_oauth_access_tokens_on_application_id"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "pg_search_documents", force: :cascade do |t|
    t.text "content"
    t.string "searchable_type"
    t.bigint "searchable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["searchable_type", "searchable_id"], name: "index_pg_search_documents_on_searchable_type_and_searchable_id"
  end

  create_table "ripples_transactions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "wallet_id"
    t.string "destination"
    t.string "tx_hash"
    t.decimal "amount", precision: 15, scale: 2, default: "0.0"
    t.string "source_currency"
    t.string "destination_currency"
    t.string "state"
    t.string "transaction_type"
    t.integer "transaction_date"
    t.datetime "deleted_at"
    t.boolean "validated", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "source"
    t.index ["deleted_at"], name: "index_ripples_transactions_on_deleted_at"
    t.index ["destination"], name: "index_ripples_transactions_on_destination"
    t.index ["source"], name: "index_ripples_transactions_on_source"
    t.index ["tx_hash"], name: "index_ripples_transactions_on_tx_hash"
    t.index ["wallet_id"], name: "index_ripples_transactions_on_wallet_id"
  end

  create_table "ripples_wallets", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id"
    t.integer "sequence"
    t.string "label"
    t.string "address"
    t.string "encrypted_secret"
    t.string "encrypted_secret_iv"
    t.string "seed"
    t.boolean "validated", default: false
    t.decimal "balance", precision: 15, scale: 2, default: "0.0"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_ripples_wallets_on_account_id"
    t.index ["address"], name: "index_ripples_wallets_on_address", unique: true
    t.index ["deleted_at"], name: "index_ripples_wallets_on_deleted_at"
    t.index ["label"], name: "index_ripples_wallets_on_label"
    t.index ["validated"], name: "index_ripples_wallets_on_validated"
  end

  create_table "settingable_settings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "settingable_type"
    t.uuid "settingable_id"
    t.text "options"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_settingable_settings_on_deleted_at"
    t.index ["settingable_type", "settingable_id"], name: "settingable_settings_type_and_setingable_id"
  end

  create_table "supports_encrypted_requests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "requester_type"
    t.uuid "requester_id"
    t.string "context_type"
    t.uuid "context_id"
    t.text "encrypted_data"
    t.string "state"
    t.datetime "expired_at"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["context_type", "context_id"], name: "supports_encrypted_requests_context"
    t.index ["deleted_at"], name: "index_supports_encrypted_requests_on_deleted_at"
    t.index ["requester_type", "requester_id"], name: "supports_encrypted_requests_requester"
  end

  create_table "supports_notifications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "notifiable_type"
    t.uuid "notifiable_id"
    t.string "sender_type"
    t.uuid "sender_id"
    t.string "code"
    t.string "subject", default: ""
    t.text "body"
    t.string "state"
    t.datetime "deleted_at"
    t.string "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_supports_notifications_on_code"
    t.index ["deleted_at"], name: "index_supports_notifications_on_deleted_at"
    t.index ["notifiable_type", "notifiable_id"], name: "supports_notifications_notifiable_type_and_notifiable_id"
    t.index ["sender_type", "sender_id"], name: "supports_notifications_sender"
    t.index ["type"], name: "index_supports_notifications_on_type"
  end

  create_table "supports_receipts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "notification_id"
    t.string "recipient_type"
    t.uuid "recipient_id"
    t.string "state"
    t.boolean "is_read"
    t.boolean "is_trashed"
    t.string "mailbox_type"
    t.text "options"
    t.datetime "scheduled_at"
    t.datetime "deleted_at"
    t.string "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_supports_receipts_on_deleted_at"
    t.index ["is_read"], name: "index_supports_receipts_on_is_read"
    t.index ["is_trashed"], name: "index_supports_receipts_on_is_trashed"
    t.index ["notification_id"], name: "index_supports_receipts_on_notification_id"
    t.index ["recipient_type", "recipient_id"], name: "supports_receipts_recipient"
    t.index ["state"], name: "index_supports_receipts_on_state"
    t.index ["type"], name: "index_supports_receipts_on_type"
  end

  create_table "users_accounts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "username"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "token"
    t.string "encrypted_pin"
    t.string "encrypted_pin_iv"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_accounts_on_confirmation_token", unique: true
    t.index ["deleted_at"], name: "index_users_accounts_on_deleted_at"
    t.index ["email"], name: "index_users_accounts_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_accounts_on_reset_password_token", unique: true
    t.index ["token"], name: "index_users_accounts_on_token", unique: true
    t.index ["unlock_token"], name: "index_users_accounts_on_unlock_token", unique: true
    t.index ["username"], name: "index_users_accounts_on_username", unique: true
  end

  create_table "users_plans", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.text "features"
    t.text "description"
    t.decimal "price", precision: 15, scale: 2, default: "0.0"
    t.string "currency"
    t.integer "position", default: 1
    t.string "state"
    t.boolean "free", default: false
    t.string "per_period", default: "month"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_users_plans_on_code"
    t.index ["deleted_at"], name: "index_users_plans_on_deleted_at"
    t.index ["name"], name: "index_users_plans_on_name"
    t.index ["price"], name: "index_users_plans_on_price"
  end

  create_table "users_subscriptions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.uuid "account_id"
    t.uuid "plan_id"
    t.decimal "amount", precision: 50, scale: 35, default: "0.0"
    t.string "coin"
    t.datetime "expired_at"
    t.string "state"
    t.string "txn_id"
    t.string "qrcode_url"
    t.string "status_url"
    t.string "payment_address"
    t.string "notification_email"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_users_subscriptions_on_account_id"
    t.index ["deleted_at"], name: "index_users_subscriptions_on_deleted_at"
    t.index ["expired_at"], name: "index_users_subscriptions_on_expired_at"
    t.index ["name"], name: "index_users_subscriptions_on_name"
    t.index ["plan_id"], name: "index_users_subscriptions_on_plan_id"
  end

  create_table "users_tokens", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "token"
    t.uuid "account_id"
    t.datetime "expired_at", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_users_tokens_on_account_id"
    t.index ["deleted_at"], name: "index_users_tokens_on_deleted_at"
    t.index ["token"], name: "index_users_tokens_on_token"
  end

  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
end
