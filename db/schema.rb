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

ActiveRecord::Schema.define(version: 20161222163255) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addresses", force: :cascade do |t|
    t.string   "street_address"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "type"
  end

  create_table "participants", force: :cascade do |t|
    t.date     "date_of_birth"
    t.string   "first_name"
    t.string   "gender"
    t.string   "last_name"
    t.string   "ssn"
    t.integer  "screening_id"
    t.integer  "person_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["person_id"], name: "index_participants_on_person_id", using: :btree
    t.index ["screening_id"], name: "index_participants_on_screening_id", using: :btree
  end

  create_table "people", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "gender"
    t.string   "ssn"
    t.date     "date_of_birth"
    t.string   "middle_name"
    t.string   "name_suffix"
    t.string   "languages",     default: [],              array: true
  end

  create_table "person_addresses", force: :cascade do |t|
    t.integer  "person_id"
    t.integer  "address_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["address_id"], name: "index_person_addresses_on_address_id", using: :btree
    t.index ["person_id"], name: "index_person_addresses_on_person_id", using: :btree
  end

  create_table "person_phone_numbers", force: :cascade do |t|
    t.integer  "person_id"
    t.integer  "phone_number_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["person_id"], name: "index_person_phone_numbers_on_person_id", using: :btree
    t.index ["phone_number_id"], name: "index_person_phone_numbers_on_phone_number_id", using: :btree
  end

  create_table "phone_numbers", force: :cascade do |t|
    t.string   "number"
    t.string   "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "screening_addresses", force: :cascade do |t|
    t.integer  "screening_id"
    t.integer  "address_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["address_id"], name: "index_screening_addresses_on_address_id", using: :btree
    t.index ["screening_id"], name: "index_screening_addresses_on_screening_id", using: :btree
  end

  create_table "screenings", force: :cascade do |t|
    t.string   "reference"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.datetime "ended_at"
    t.date     "incident_date"
    t.string   "location_type"
    t.string   "communication_method"
    t.string   "name"
    t.datetime "started_at"
    t.string   "response_time"
    t.string   "screening_decision"
    t.string   "incident_county"
    t.text     "report_narrative"
  end

end
