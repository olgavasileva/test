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

ActiveRecord::Schema.define(version: 20140508002445) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "answers", force: true do |t|
    t.integer  "user_id"
    t.integer  "question_id"
    t.boolean  "agree"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "answers", ["question_id"], name: "index_answers_on_question_id", using: :btree
  add_index "answers", ["user_id", "question_id"], name: "index_answers_on_user_id_and_question_id", unique: true, using: :btree
  add_index "answers", ["user_id"], name: "index_answers_on_user_id", using: :btree

  create_table "categories", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "category_type"
  end

  create_table "choices", force: true do |t|
    t.string   "label"
    t.string   "image_url"
    t.string   "description"
    t.integer  "question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "choices", ["question_id"], name: "index_choices_on_question_id", using: :btree

  create_table "comments", force: true do |t|
    t.string   "content"
    t.integer  "user_id"
    t.integer  "question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["question_id"], name: "index_comments_on_question_id", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "devices", force: true do |t|
    t.string   "udid"
    t.string   "device_type"
    t.string   "os_version"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "friendships", force: true do |t|
    t.integer  "user_id"
    t.integer  "friend_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "friendships", ["friend_id"], name: "index_friendships_on_friend_id", using: :btree
  add_index "friendships", ["user_id", "friend_id"], name: "index_friendships_on_user_id_and_friend_id", unique: true, using: :btree
  add_index "friendships", ["user_id"], name: "index_friendships_on_user_id", using: :btree

  create_table "inclusions", force: true do |t|
    t.integer  "pack_id"
    t.integer  "question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "inclusions", ["pack_id", "question_id"], name: "index_inclusions_on_pack_id_and_question_id", unique: true, using: :btree
  add_index "inclusions", ["pack_id"], name: "index_inclusions_on_pack_id", using: :btree
  add_index "inclusions", ["question_id"], name: "index_inclusions_on_question_id", using: :btree

  create_table "microposts", force: true do |t|
    t.string   "content"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "microposts", ["user_id", "created_at"], name: "index_microposts_on_user_id_and_created_at", using: :btree

  create_table "ownerships", force: true do |t|
    t.integer  "user_id"
    t.integer  "device_id"
    t.string   "remember_token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ownerships", ["device_id"], name: "index_ownerships_on_device_id", using: :btree
  add_index "ownerships", ["remember_token"], name: "index_ownerships_on_remember_token", using: :btree
  add_index "ownerships", ["user_id", "device_id"], name: "index_ownerships_on_user_id_and_device_id", unique: true, using: :btree
  add_index "ownerships", ["user_id"], name: "index_ownerships_on_user_id", using: :btree

  create_table "packs", force: true do |t|
    t.string   "title"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "packs", ["user_id"], name: "index_packs_on_user_id", using: :btree

  create_table "questions", force: true do |t|
    t.string   "title"
    t.string   "info"
    t.string   "image_url"
    t.integer  "question_type"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "category_id"
    t.integer  "min_value"
    t.integer  "max_value"
    t.integer  "interval"
    t.string   "units"
    t.boolean  "hidden",        default: false
    t.boolean  "special_case",  default: false
    t.boolean  "sponsored",     default: false
  end

  add_index "questions", ["category_id"], name: "index_questions_on_category_id", using: :btree
  add_index "questions", ["user_id"], name: "index_questions_on_user_id", using: :btree

  create_table "relationships", force: true do |t|
    t.integer  "follower_id"
    t.integer  "followed_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "relationships", ["followed_id"], name: "index_relationships_on_followed_id", using: :btree
  add_index "relationships", ["follower_id", "followed_id"], name: "index_relationships_on_follower_id_and_followed_id", unique: true, using: :btree
  add_index "relationships", ["follower_id"], name: "index_relationships_on_follower_id", using: :btree

  create_table "responses", force: true do |t|
    t.integer  "order"
    t.float    "percent"
    t.integer  "star"
    t.integer  "choice_id"
    t.integer  "answer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "slider"
  end

  add_index "responses", ["answer_id"], name: "index_responses_on_answer_id", using: :btree
  add_index "responses", ["choice_id"], name: "index_responses_on_choice_id", using: :btree

  create_table "sharings", force: true do |t|
    t.integer  "sender_id"
    t.integer  "receiver_id"
    t.integer  "question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sharings", ["question_id"], name: "index_sharings_on_question_id", using: :btree
  add_index "sharings", ["receiver_id"], name: "index_sharings_on_receiver_id", using: :btree
  add_index "sharings", ["sender_id", "receiver_id", "question_id"], name: "index_sharings_on_sender_id_and_receiver_id_and_question_id", unique: true, using: :btree
  add_index "sharings", ["sender_id"], name: "index_sharings_on_sender_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_digest"
    t.string   "remember_token"
    t.boolean  "admin",           default: false
    t.string   "username"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["remember_token"], name: "index_users_on_remember_token", using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

end
