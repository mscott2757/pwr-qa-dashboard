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

ActiveRecord::Schema.define(version: 20170728173806) do

  create_table "application_tags", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "threshold", default: 100
    t.integer "group", default: 10
  end

  create_table "environment_tags", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "setting_id"
  end

  create_table "jira_tickets", force: :cascade do |t|
    t.string "number"
    t.integer "test_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "resolved", default: false
    t.datetime "updtated"
    t.text "summary"
    t.string "assignee"
    t.string "reporter"
    t.string "status"
    t.datetime "created"
    t.datetime "updated"
  end

  create_table "notes", force: :cascade do |t|
    t.string "author"
    t.text "body"
    t.integer "test_id"
    t.integer "application_tag_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "settings", force: :cascade do |t|
    t.boolean "rotate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "test_application_tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "test_id"
    t.integer "application_tag_id"
  end

  create_table "test_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tests", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status"
    t.string "job_url"
    t.integer "last_successful_build"
    t.integer "environment_tag_id"
    t.integer "last_build"
    t.integer "primary_app_id"
    t.datetime "last_build_time"
    t.datetime "last_successful_build_time"
    t.boolean "parameterized", default: false
    t.integer "test_type_id"
    t.string "internal_name"
    t.integer "group", default: 10
  end

end
