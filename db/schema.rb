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

ActiveRecord::Schema.define(version: 2018_05_05_165737) do

  create_table "airlines", force: :cascade do |t|
    t.string "iata_code"
    t.string "name"
    t.index ["iata_code"], name: "index_airlines_on_iata_code", unique: true
  end

  create_table "airports", force: :cascade do |t|
    t.string "iata_code"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["iata_code"], name: "index_airports_on_iata_code", unique: true
  end

  create_table "events", force: :cascade do |t|
    t.text "event_name"
    t.text "arriving_timezone"
    t.text "departing_timezone"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "share_link"
    t.text "note"
    t.string "timezone"
    t.index ["user_id"], name: "index_events_on_user_id"
  end

  create_table "flights", force: :cascade do |t|
    t.integer "flight_number"
    t.datetime "departure_datetime"
    t.datetime "arrival_datetime"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "traveler_id"
    t.integer "airline_id"
    t.integer "departure_airport_id"
    t.integer "arrival_airport_id"
    t.boolean "is_arrival"
  end

  create_table "travelers", force: :cascade do |t|
    t.text "traveler_name"
    t.text "traveler_note"
    t.text "arrival_info"
    t.boolean "is_arrival"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "event_id"
    t.text "departure_info"
    t.index ["event_id"], name: "index_travelers_on_event_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "remember_digest"
    t.boolean "admin", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
