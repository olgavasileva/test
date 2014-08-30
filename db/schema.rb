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

ActiveRecord::Schema.define(version: 20140828210226) do

  create_table "active_admin_comments", force: true do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "admin_users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree

  create_table "authentications", force: true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.string   "token"
    t.string   "token_secret"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "authentications", ["user_id"], name: "index_authentications_on_user_id", using: :btree

  create_table "background_images", force: true do |t|
    t.string   "image"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
  end

  create_table "categories", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "icon"
  end

  create_table "choices", force: true do |t|
    t.integer  "question_id"
    t.text     "title"
    t.integer  "position"
    t.boolean  "rotate"
    t.boolean  "muex"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "background_image_id"
    t.string   "type"
  end

  add_index "choices", ["question_id"], name: "index_choices_on_question_id", using: :btree

  create_table "choices_responses", force: true do |t|
    t.integer  "multiple_choice_id"
    t.integer  "multiple_choice_response_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "devices", force: true do |t|
    t.string   "device_vendor_identifier"
    t.string   "platform"
    t.string   "os_version"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "manufacturer"
    t.string   "model"
  end

  create_table "feed_items", force: true do |t|
    t.integer  "user_id"
    t.integer  "question_id"
    t.string   "reason"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "feed_items", ["question_id"], name: "index_feed_items_on_question_id", using: :btree
  add_index "feed_items", ["user_id"], name: "index_feed_items_on_user_id", using: :btree

  create_table "group_members", force: true do |t|
    t.integer  "group_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "group_members", ["group_id"], name: "index_group_members_on_group_id", using: :btree
  add_index "group_members", ["user_id"], name: "index_group_members_on_user_id", using: :btree

  create_table "groups", force: true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "groups", ["user_id"], name: "index_groups_on_user_id", using: :btree

  create_table "inclusions", force: true do |t|
    t.integer  "pack_id"
    t.integer  "question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "inclusions", ["pack_id", "question_id"], name: "index_inclusions_on_pack_id_and_question_id", unique: true, using: :btree
  add_index "inclusions", ["pack_id"], name: "index_inclusions_on_pack_id", using: :btree
  add_index "inclusions", ["question_id"], name: "index_inclusions_on_question_id", using: :btree

  create_table "inquiries", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "instances", force: true do |t|
    t.string   "uuid"
    t.integer  "device_id"
    t.integer  "user_id"
    t.string   "push_app_name"
    t.string   "push_environment"
    t.string   "push_token"
    t.integer  "launch_count"
    t.string   "auth_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "app_version"
  end

  add_index "instances", ["device_id"], name: "index_instances_on_device_id", using: :btree
  add_index "instances", ["user_id"], name: "index_instances_on_user_id", using: :btree

  create_table "liked_comments", force: true do |t|
    t.integer  "user_id"
    t.integer  "response_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "liked_comments", ["response_id"], name: "index_liked_comments_on_response_id", using: :btree
  add_index "liked_comments", ["user_id"], name: "index_liked_comments_on_user_id", using: :btree

  create_table "order_choices_responses", force: true do |t|
    t.integer  "order_choice_id"
    t.integer  "order_response_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
  end

  create_table "packs", force: true do |t|
    t.string   "title"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "packs", ["user_id"], name: "index_packs_on_user_id", using: :btree

  create_table "partners", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
  end

  add_index "partners", ["email"], name: "index_partners_on_email", unique: true, using: :btree
  add_index "partners", ["reset_password_token"], name: "index_partners_on_reset_password_token", unique: true, using: :btree

  create_table "percent_choices_responses", force: true do |t|
    t.integer  "percent_choice_id"
    t.integer  "percent_response_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "percent"
  end

  create_table "questions", force: true do |t|
    t.integer  "user_id"
    t.integer  "category_id"
    t.text     "title"
    t.string   "description"
    t.boolean  "rotate"
    t.string   "type"
    t.integer  "position"
    t.boolean  "show_question_results"
    t.integer  "weight"
    t.string   "html"
    t.string   "text_type"
    t.integer  "min_characters"
    t.integer  "max_characters"
    t.integer  "min_responses"
    t.integer  "max_responses"
    t.integer  "max_stars"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "background_image_id"
    t.string   "state"
    t.string   "kind"
  end

  add_index "questions", ["background_image_id"], name: "index_questions_on_background_image_id", using: :btree
  add_index "questions", ["category_id"], name: "index_questions_on_category_id", using: :btree
  add_index "questions", ["created_at"], name: "index_questions_on_created_at", using: :btree
  add_index "questions", ["kind"], name: "index_questions_on_kind", using: :btree
  add_index "questions", ["user_id"], name: "index_questions_on_user_id", using: :btree

  create_table "relationships", force: true do |t|
    t.integer  "follower_id"
    t.integer  "leader_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "relationships", ["follower_id", "leader_id"], name: "index_relationships_on_follower_id_and_leader_id", unique: true, using: :btree
  add_index "relationships", ["follower_id"], name: "index_relationships_on_follower_id", using: :btree
  add_index "relationships", ["leader_id"], name: "index_relationships_on_leader_id", using: :btree

  create_table "responses", force: true do |t|
    t.string   "type"
    t.integer  "user_id"
    t.integer  "question_id"
    t.string   "image"
    t.text     "text"
    t.integer  "choice_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "comment"
    t.boolean  "anonymous"
  end

  add_index "responses", ["choice_id"], name: "index_responses_on_choice_id", using: :btree
  add_index "responses", ["question_id"], name: "index_responses_on_question_id", using: :btree
  add_index "responses", ["user_id"], name: "index_responses_on_user_id", using: :btree

  create_table "roles", force: true do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "settings", force: true do |t|
    t.boolean  "enabled"
    t.string   "key"
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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

  create_table "skipped_items", force: true do |t|
    t.integer  "user_id"
    t.integer  "question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "skipped_items", ["question_id"], name: "index_skipped_items_on_question_id", using: :btree
  add_index "skipped_items", ["user_id"], name: "index_skipped_items_on_user_id", using: :btree

  create_table "star_choices_responses", force: true do |t|
    t.integer  "star_choice_id"
    t.integer  "star_response_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "stars"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username"
    t.string   "name"
    t.string   "remember_token"
    t.string   "longitude"
    t.string   "latitude"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "users_roles", id: false, force: true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree

end
