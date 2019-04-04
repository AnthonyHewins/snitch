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

ActiveRecord::Schema.define(version: 2019_04_11_200750) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "cyber_adapt_alerts", force: :cascade do |t|
    t.integer "alert_id", null: false
    t.text "alert"
    t.string "msg"
    t.inet "src_ip", null: false
    t.inet "dst_ip", null: false
    t.integer "src_port", null: false
    t.integer "dst_port", null: false
    t.datetime "alert_timestamp", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "resolved", default: false
    t.text "comment"
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
  end

  create_table "machines", force: :cascade do |t|
    t.string "user"
    t.string "host"
    t.inet "ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "paper_trail_id"
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
    t.bigint "machine_id"
    t.index ["machine_id"], name: "index_uri_entries_on_machine_id"
    t.index ["paper_trail_id"], name: "index_uri_entries_on_paper_trail_id"
  end

  create_table "whitelists", force: :cascade do |t|
    t.string "regex_string"
    t.bigint "paper_trail_id"
    t.index ["paper_trail_id"], name: "index_whitelists_on_paper_trail_id"
  end

end
