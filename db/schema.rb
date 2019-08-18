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

ActiveRecord::Schema.define(version: 2019_08_18_221429) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "departments", force: :cascade do |t|
    t.string "name"
  end

  create_table "dhcp_leases", force: :cascade do |t|
    t.inet "ip", null: false
    t.bigint "machine_id"
    t.bigint "paper_trail_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["machine_id"], name: "index_dhcp_leases_on_machine_id"
    t.index ["paper_trail_id"], name: "index_dhcp_leases_on_paper_trail_id"
  end

  create_table "fs_isac_alerts", force: :cascade do |t|
    t.string "title", null: false
    t.bigint "tracking_id", null: false
    t.datetime "alert_timestamp", null: false
    t.text "alert", null: false
    t.text "affected_products", null: false
    t.text "corrective_action", null: false
    t.text "sources", null: false
    t.boolean "resolved", default: false
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "applies", default: true
    t.integer "severity"
  end

  create_table "fs_isac_ignores", force: :cascade do |t|
    t.string "regex_string", null: false
    t.boolean "case_sensitive", default: false
  end

  create_table "machines", force: :cascade do |t|
    t.string "user"
    t.string "host"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "paper_trail_id"
    t.bigint "department_id"
    t.index ["department_id"], name: "index_machines_on_department_id"
    t.index ["paper_trail_id"], name: "index_machines_on_paper_trail_id"
  end

  create_table "paper_trails", force: :cascade do |t|
    t.string "filename"
    t.date "insertion_date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "uri_entries", force: :cascade do |t|
    t.string "uri"
    t.integer "hits"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "paper_trail_id"
    t.bigint "dhcp_lease_id"
    t.index ["dhcp_lease_id"], name: "index_uri_entries_on_dhcp_lease_id"
    t.index ["paper_trail_id"], name: "index_uri_entries_on_paper_trail_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "password_digest"
    t.boolean "admin"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "whitelists", force: :cascade do |t|
    t.string "regex_string"
  end

end
