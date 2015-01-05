# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20141227082237) do

  create_table "businesses", force: true do |t|
    t.string   "name"
    t.string   "website"
    t.string   "phone_number"
    t.string   "rating"
    t.integer  "price"
    t.string   "street_address"
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.string   "postal_code"
    t.string   "zipcode"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "businesses_categories", force: true do |t|
    t.integer  "category_id"
    t.integer  "business_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "businesses_categories", ["business_id"], name: "index_businesses_categories_on_business_id", using: :btree
  add_index "businesses_categories", ["category_id", "business_id"], name: "index_businesses_categories_on_category_id_and_business_id", unique: true, using: :btree
  add_index "businesses_categories", ["category_id"], name: "index_businesses_categories_on_category_id", using: :btree

  create_table "links", force: true do |t|
    t.string   "biz_link"
    t.integer  "business_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "links", ["business_id"], name: "index_links_on_business_id", using: :btree

end