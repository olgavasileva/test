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

ActiveRecord::Schema.define(version: 20151111062402) do

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

  create_table "ad_units", force: true do |t|
    t.string   "name"
    t.text     "default_meta_data"
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "related_surveys_count", default: 3, null: false
  end

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
    t.text     "token"
    t.text     "token_secret"
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

  create_table "background_images_ad_units", force: true do |t|
    t.integer  "background_image_id"
    t.integer  "ad_unit_id"
    t.text     "meta_data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "background_images_ad_units", ["ad_unit_id"], name: "index_background_images_ad_units_on_ad_unit_id", using: :btree
  add_index "background_images_ad_units", ["background_image_id"], name: "index_background_images_ad_units_on_background_image_id", using: :btree

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
    t.text     "targeting_script"
  end

  add_index "choices", ["question_id"], name: "index_choices_on_question_id", using: :btree

  create_table "choices_responses", force: true do |t|
    t.integer  "multiple_choice_id"
    t.integer  "multiple_choice_response_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", force: true do |t|
    t.text     "body"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "commentable_id"
    t.string   "commentable_type"
  end

  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "communities", force: true do |t|
    t.string   "name"
    t.boolean  "private",               default: false
    t.string   "password"
    t.string   "password_confirmation"
    t.text     "description"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "communities", ["user_id"], name: "index_communities_on_user_id", using: :btree

  create_table "communities_targets", force: true do |t|
    t.integer  "target_id"
    t.integer  "community_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "communities_targets", ["community_id"], name: "index_communities_targets_on_community_id", using: :btree
  add_index "communities_targets", ["target_id"], name: "index_communities_targets_on_target_id", using: :btree

  create_table "community_members", force: true do |t|
    t.integer  "community_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "community_members", ["community_id"], name: "index_community_members_on_community_id", using: :btree
  add_index "community_members", ["user_id"], name: "index_community_members_on_user_id", using: :btree

  create_table "contest_response_votes", force: true do |t|
    t.integer  "contest_id"
    t.integer  "response_id"
    t.integer  "vote_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contest_response_votes", ["contest_id"], name: "index_contest_response_votes_on_contest_id", using: :btree
  add_index "contest_response_votes", ["response_id"], name: "index_contest_response_votes_on_response_id", using: :btree

  create_table "contests", force: true do |t|
    t.integer  "survey_id"
    t.integer  "key_question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "uuid"
    t.text     "heading_markdown"
    t.text     "heading_html"
    t.text     "gallery_heading_markdown"
    t.text     "gallery_heading_html"
    t.boolean  "allow_anonymous_votes",    default: false
  end

  add_index "contests", ["key_question_id"], name: "index_contests_on_key_question_id", using: :btree
  add_index "contests", ["survey_id"], name: "index_contests_on_survey_id", using: :btree

  create_table "daily_analytics", force: true do |t|
    t.integer  "user_id"
    t.string   "metric"
    t.integer  "total"
    t.date     "date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "daily_analytics", ["user_id", "metric", "date"], name: "index_daily_analytics_on_user_id_and_metric_and_date", using: :btree

  create_table "data_providers", force: true do |t|
    t.string   "name"
    t.integer  "priority"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "demographic_summaries", force: true do |t|
    t.string   "gender"
    t.string   "age_range"
    t.string   "household_income"
    t.string   "children"
    t.string   "ethnicity"
    t.string   "education_level"
    t.string   "political_affiliation"
    t.string   "political_engagement"
    t.integer  "respondent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ip_address"
    t.string   "country"
  end

  add_index "demographic_summaries", ["country"], name: "index_demographic_summaries_on_country", using: :btree
  add_index "demographic_summaries", ["respondent_id"], name: "index_demographic_summaries_on_respondent_id", using: :btree

  create_table "demographics", force: true do |t|
    t.string   "gender"
    t.string   "age_range"
    t.string   "household_income"
    t.string   "children"
    t.string   "ethnicity"
    t.string   "education_level"
    t.string   "political_affiliation"
    t.string   "political_engagement"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "respondent_id"
    t.text     "raw_data"
    t.string   "data_version"
    t.integer  "data_provider_id"
    t.string   "ip_address"
    t.string   "country"
    t.text     "user_agent"
  end

  add_index "demographics", ["country"], name: "index_demographics_on_country", using: :btree
  add_index "demographics", ["data_provider_id"], name: "index_demographics_on_data_provider_id", using: :btree

  create_table "devices", force: true do |t|
    t.string   "device_vendor_identifier"
    t.string   "platform"
    t.string   "os_version"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "manufacturer"
    t.string   "model"
  end

  create_table "embeddable_unit_themes", force: true do |t|
    t.string  "title",      null: false
    t.string  "main_color", null: false
    t.string  "color1",     null: false
    t.string  "color2",     null: false
    t.integer "user_id"
  end

  create_table "embeddable_units", force: true do |t|
    t.string   "uuid"
    t.integer  "survey_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "width"
    t.integer  "height"
    t.text     "thank_you_markdown"
    t.text     "thank_you_html"
  end

  add_index "embeddable_units", ["survey_id"], name: "index_embeddable_units_on_survey_id", using: :btree

  create_table "enterprise_targets_segments", force: true do |t|
    t.integer  "enterprise_target_id"
    t.integer  "segment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "enterprise_targets_segments", ["enterprise_target_id"], name: "index_enterprise_targets_segments_on_enterprise_target_id", using: :btree
  add_index "enterprise_targets_segments", ["segment_id"], name: "index_enterprise_targets_segments_on_segment_id", using: :btree

  create_table "feed_items", force: true do |t|
    t.integer  "user_id"
    t.integer  "question_id"
    t.string   "reason"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "feed_items", ["question_id"], name: "index_feed_items_on_question_id", using: :btree
  add_index "feed_items", ["user_id"], name: "index_feed_items_on_user_id", using: :btree

  create_table "feed_items_v2", force: true do |t|
    t.integer  "user_id"
    t.integer  "question_id"
    t.datetime "published_at"
    t.datetime "hidden_at"
    t.boolean  "hidden"
    t.string   "hidden_reason"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "relevance",     default: 0
    t.string   "why"
  end

  add_index "feed_items_v2", ["hidden", "hidden_reason", "question_id"], name: "idx2", using: :btree
  add_index "feed_items_v2", ["hidden", "why"], name: "index_feed_items_v2_on_hidden_and_why", using: :btree
  add_index "feed_items_v2", ["question_id"], name: "index_feed_items_v2_on_question_id", using: :btree
  add_index "feed_items_v2", ["user_id", "hidden", "hidden_reason", "question_id"], name: "idx5", using: :btree
  add_index "feed_items_v2", ["user_id", "hidden", "published_at"], name: "idx3", using: :btree
  add_index "feed_items_v2", ["why"], name: "index_feed_items_v2_on_why", using: :btree

  create_table "follower_targets", force: true do |t|
    t.integer  "question_id"
    t.integer  "follower_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "follower_targets", ["follower_id"], name: "index_follower_targets_on_follower_id", using: :btree
  add_index "follower_targets", ["question_id"], name: "index_follower_targets_on_question_id", using: :btree

  create_table "galleries", force: true do |t|
    t.datetime "entries_open"
    t.datetime "entries_close"
    t.datetime "voting_open"
    t.datetime "voting_close"
    t.integer  "total_votes"
    t.integer  "user_id"
    t.integer  "gallery_template_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "galleries", ["gallery_template_id"], name: "index_galleries_on_gallery_template_id", using: :btree

  create_table "gallery_element_votes", force: true do |t|
    t.integer  "gallery_element_id"
    t.integer  "votes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  add_index "gallery_element_votes", ["gallery_element_id"], name: "index_gallery_element_votes_on_gallery_element_id", using: :btree
  add_index "gallery_element_votes", ["user_id"], name: "index_gallery_element_votes_on_user_id", using: :btree

  create_table "gallery_elements", force: true do |t|
    t.integer  "scene_id"
    t.integer  "gallery_id"
    t.integer  "user_id"
    t.integer  "votes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gallery_elements", ["gallery_id"], name: "index_gallery_elements_on_gallery_id", using: :btree
  add_index "gallery_elements", ["scene_id"], name: "index_gallery_elements_on_scene_id", using: :btree
  add_index "gallery_elements", ["user_id"], name: "index_gallery_elements_on_user_id", using: :btree

  create_table "gallery_templates", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "image"
    t.boolean  "contest",         default: false
    t.text     "rules"
    t.string   "recurrence"
    t.datetime "entries_open"
    t.datetime "entries_close"
    t.datetime "voting_open"
    t.datetime "voting_close"
    t.integer  "num_occurrences"
    t.integer  "studio_id"
    t.integer  "max_votes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "confirm_message"
    t.integer  "num_winners"
  end

  add_index "gallery_templates", ["studio_id"], name: "index_gallery_templates_on_studio_id", using: :btree

  create_table "group_members", force: true do |t|
    t.integer  "group_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "group_members", ["group_id"], name: "index_group_members_on_group_id", using: :btree
  add_index "group_members", ["user_id"], name: "index_group_members_on_user_id", using: :btree

  create_table "group_targets", force: true do |t|
    t.integer  "question_id"
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "group_targets", ["group_id"], name: "index_group_targets_on_group_id", using: :btree
  add_index "group_targets", ["question_id"], name: "index_group_targets_on_question_id", using: :btree

  create_table "groups", force: true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "groups", ["user_id"], name: "index_groups_on_user_id", using: :btree

  create_table "groups_targets", force: true do |t|
    t.integer  "group_id"
    t.integer  "target_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "groups_targets", ["group_id"], name: "index_groups_targets_on_group_id", using: :btree
  add_index "groups_targets", ["target_id"], name: "index_groups_targets_on_target_id", using: :btree

  create_table "inappropriate_flags", force: true do |t|
    t.integer  "question_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "reason"
  end

  add_index "inappropriate_flags", ["question_id"], name: "index_inappropriate_flags_on_question_id", using: :btree
  add_index "inappropriate_flags", ["user_id"], name: "index_inappropriate_flags_on_user_id", using: :btree

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
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "app_version"
    t.string   "auth_token"
  end

  add_index "instances", ["auth_token"], name: "index_instances_on_auth_token", using: :btree
  add_index "instances", ["device_id"], name: "index_instances_on_device_id", using: :btree
  add_index "instances", ["user_id"], name: "index_instances_on_user_id", using: :btree

  create_table "item_properties", force: true do |t|
    t.string   "key"
    t.string   "value"
    t.integer  "item_id"
    t.string   "item_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "item_properties", ["item_id", "item_type"], name: "index_item_properties_on_item_id_and_item_type", using: :btree

  create_table "keys", force: true do |t|
    t.string   "key"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "languages", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "liked_comments", force: true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "comment_id"
  end

  add_index "liked_comments", ["comment_id"], name: "index_liked_comments_on_comment_id", using: :btree
  add_index "liked_comments", ["user_id"], name: "index_liked_comments_on_user_id", using: :btree

  create_table "listicle_questions", force: true do |t|
    t.text     "body"
    t.integer  "listicle_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "script"
  end

  create_table "listicle_responses", force: true do |t|
    t.integer  "user_id",                           null: false
    t.integer  "question_id",                       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_up",             default: false
    t.integer  "score",             default: 0,     null: false
    t.integer  "vote_count",        default: 1,     null: false
    t.string   "original_referrer"
  end

  add_index "listicle_responses", ["created_at"], name: "index_listicle_responses_on_created_at", using: :btree
  add_index "listicle_responses", ["original_referrer"], name: "index_listicle_responses_on_original_referrer", length: {"original_referrer"=>200}, using: :btree

  create_table "listicles", force: true do |t|
    t.text     "intro"
    t.integer  "user_id"
    t.text     "footer"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "view_count",            default: 0, null: false
    t.string   "item_separator_color"
    t.string   "vote_count_color"
    t.string   "arrows_default_color"
    t.string   "arrows_on_hover_color"
    t.string   "arrows_selected_color"
  end

  create_table "localizations", force: true do |t|
    t.integer  "language_id"
    t.integer  "localizable_id"
    t.string   "localizable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "localizations", ["language_id"], name: "index_localizations_on_language_id", using: :btree

  create_table "messages", force: true do |t|
    t.text     "content"
    t.string   "type"
    t.datetime "read_at"
    t.integer  "other_user_id"
    t.integer  "question_id"
    t.integer  "response_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "response_count", default: 0
    t.integer  "comment_count",  default: 0
    t.integer  "share_count",    default: 0
    t.datetime "completed_at"
    t.integer  "follower_id"
    t.text     "body"
  end

  add_index "messages", ["user_id"], name: "index_messages_on_user_id", using: :btree

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
    t.float    "percent",             limit: 24
  end

  create_table "question_actions", force: true do |t|
    t.string   "type"
    t.integer  "question_id"
    t.integer  "respondent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "question_actions", ["question_id"], name: "index_question_actions_on_question_id", using: :btree
  add_index "question_actions", ["respondent_id"], name: "index_question_actions_on_respondent_id", using: :btree
  add_index "question_actions", ["type", "respondent_id"], name: "index_question_actions_on_type_and_respondent_id", using: :btree

  create_table "question_reports", force: true do |t|
    t.integer  "question_id"
    t.integer  "user_id"
    t.text     "reason"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "question_reports", ["question_id"], name: "index_question_reports_on_question_id", using: :btree
  add_index "question_reports", ["user_id"], name: "index_question_reports_on_user_id", using: :btree

  create_table "question_targets", force: true do |t|
    t.integer  "respondent_id"
    t.integer  "question_id"
    t.integer  "target_id"
    t.integer  "relevance",     default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "question_targets", ["question_id"], name: "index_question_targets_on_question_id", using: :btree
  add_index "question_targets", ["respondent_id"], name: "index_question_targets_on_respondent_id", using: :btree
  add_index "question_targets", ["target_id"], name: "index_question_targets_on_target_id", using: :btree

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
    t.integer  "studio_id"
    t.integer  "legacy_view_count"
    t.integer  "legacy_start_count"
    t.boolean  "target_all",                                                default: false
    t.boolean  "target_all_followers",                                      default: false
    t.boolean  "target_all_groups",                                         default: false
    t.integer  "targeted_reach"
    t.string   "uuid"
    t.boolean  "anonymous",                                                 default: false
    t.boolean  "currently_targetable",                                      default: true
    t.integer  "target_id"
    t.integer  "share_count"
    t.decimal  "score",                            precision: 10, scale: 2, default: 0.0
    t.boolean  "special",                                                   default: false
    t.boolean  "require_comment",                                           default: false
    t.integer  "trending_multiplier",                                       default: 1
    t.boolean  "disable_question_controls",                                 default: false
    t.boolean  "allow_multiple_answers_from_user",                          default: false
    t.boolean  "notifying",                                                 default: false
    t.integer  "trend_id"
    t.integer  "view_count"
    t.integer  "recent_responses_count",                                    default: 0
  end

  add_index "questions", ["background_image_id"], name: "index_questions_on_background_image_id", using: :btree
  add_index "questions", ["category_id"], name: "index_questions_on_category_id", using: :btree
  add_index "questions", ["created_at"], name: "index_questions_on_created_at", using: :btree
  add_index "questions", ["kind"], name: "index_questions_on_kind", using: :btree
  add_index "questions", ["recent_responses_count"], name: "index_questions_on_recent_responses_count", using: :btree
  add_index "questions", ["state", "kind"], name: "index_questions_on_state_and_kind", using: :btree
  add_index "questions", ["trend_id"], name: "index_questions_on_trend_id", using: :btree
  add_index "questions", ["type"], name: "index_questions_on_type", using: :btree
  add_index "questions", ["user_id"], name: "index_questions_on_user_id", using: :btree

  create_table "questions_surveys", force: true do |t|
    t.integer  "question_id"
    t.integer  "survey_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "questions_surveys", ["question_id"], name: "index_questions_surveys_on_question_id", using: :btree
  add_index "questions_surveys", ["survey_id"], name: "index_questions_surveys_on_survey_id", using: :btree

  create_table "relationships", force: true do |t|
    t.integer  "follower_id"
    t.integer  "leader_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "relationships", ["follower_id", "leader_id"], name: "index_relationships_on_follower_id_and_leader_id", unique: true, using: :btree
  add_index "relationships", ["follower_id"], name: "index_relationships_on_follower_id", using: :btree
  add_index "relationships", ["leader_id"], name: "index_relationships_on_leader_id", using: :btree

  create_table "response_matchers", force: true do |t|
    t.integer  "segment_id"
    t.integer  "question_id"
    t.text     "regex"
    t.integer  "first_place_choice_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.string   "inclusion"
    t.integer  "choice_id"
  end

  add_index "response_matchers", ["question_id"], name: "index_response_matchers_on_question_id", using: :btree
  add_index "response_matchers", ["segment_id"], name: "index_response_matchers_on_segment_id", using: :btree

  create_table "responses", force: true do |t|
    t.string   "type"
    t.integer  "user_id"
    t.integer  "question_id"
    t.string   "image"
    t.text     "text"
    t.integer  "choice_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "anonymous"
    t.integer  "scene_id"
    t.integer  "comment_id"
    t.string   "source"
    t.text     "original_referrer"
  end

  add_index "responses", ["choice_id"], name: "index_responses_on_choice_id", using: :btree
  add_index "responses", ["comment_id"], name: "index_responses_on_comment_id", using: :btree
  add_index "responses", ["created_at"], name: "index_responses_on_created_at", using: :btree
  add_index "responses", ["original_referrer"], name: "index_responses_on_original_referrer", length: {"original_referrer"=>200}, using: :btree
  add_index "responses", ["question_id"], name: "index_responses_on_question_id", using: :btree
  add_index "responses", ["source"], name: "index_responses_on_source", using: :btree
  add_index "responses", ["type", "question_id"], name: "index_responses_on_type_and_question_id", using: :btree
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

  create_table "rpush_apps", force: true do |t|
    t.string   "name",                                null: false
    t.string   "environment"
    t.text     "certificate"
    t.string   "password"
    t.integer  "connections",             default: 1, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type",                                null: false
    t.string   "auth_key"
    t.string   "client_id"
    t.string   "client_secret"
    t.string   "access_token"
    t.datetime "access_token_expiration"
  end

  create_table "rpush_feedback", force: true do |t|
    t.string   "device_token", limit: 64, null: false
    t.datetime "failed_at",               null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "app_id"
  end

  add_index "rpush_feedback", ["device_token"], name: "index_rpush_feedback_on_device_token", using: :btree

  create_table "rpush_notifications", force: true do |t|
    t.integer  "badge"
    t.string   "device_token",      limit: 64
    t.string   "sound",                              default: "default"
    t.string   "alert"
    t.text     "data"
    t.integer  "expiry",                             default: 86400
    t.boolean  "delivered",                          default: false,     null: false
    t.datetime "delivered_at"
    t.boolean  "failed",                             default: false,     null: false
    t.datetime "failed_at"
    t.integer  "error_code"
    t.text     "error_description"
    t.datetime "deliver_after"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "alert_is_json",                      default: false
    t.string   "type",                                                   null: false
    t.string   "collapse_key"
    t.boolean  "delay_while_idle",                   default: false,     null: false
    t.text     "registration_ids",  limit: 16777215
    t.integer  "app_id",                                                 null: false
    t.integer  "retries",                            default: 0
    t.string   "uri"
    t.datetime "fail_after"
    t.boolean  "processing",                         default: false,     null: false
    t.integer  "priority"
    t.text     "url_args"
    t.string   "category"
  end

  add_index "rpush_notifications", ["app_id", "delivered", "failed", "deliver_after"], name: "index_rapns_notifications_multi", using: :btree
  add_index "rpush_notifications", ["delivered", "failed"], name: "index_rpush_notifications_multi", using: :btree

  create_table "scenes", force: true do |t|
    t.text     "canvas_json"
    t.integer  "user_id"
    t.boolean  "deleted",     default: false
    t.string   "name"
    t.integer  "studio_id"
    t.string   "image"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "scenes", ["studio_id"], name: "index_scenes_on_studio_id", using: :btree
  add_index "scenes", ["user_id"], name: "index_scenes_on_user_id", using: :btree

  create_table "segments", force: true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.integer  "potential_reach_count"
    t.datetime "potential_reach_computed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "segments", ["user_id"], name: "index_segments_on_user_id", using: :btree

  create_table "settings", force: true do |t|
    t.boolean  "enabled"
    t.string   "key"
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "settings", ["key"], name: "index_settings_on_key", unique: true, using: :btree

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

  create_table "sticker_pack_stickers", force: true do |t|
    t.integer "sticker_pack_id"
    t.integer "sticker_id"
    t.integer "sort_order"
  end

  add_index "sticker_pack_stickers", ["sticker_id"], name: "index_sticker_pack_stickers_on_sticker_id", using: :btree
  add_index "sticker_pack_stickers", ["sticker_pack_id"], name: "index_sticker_pack_stickers_on_sticker_pack_id", using: :btree

  create_table "sticker_packs", force: true do |t|
    t.string   "display_name"
    t.boolean  "disabled"
    t.string   "klass"
    t.string   "header_icon"
    t.string   "footer_image"
    t.string   "footer_link"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "starts_at"
    t.datetime "expires_at"
    t.integer  "max_on_canvas"
  end

  create_table "stickers", force: true do |t|
    t.string   "display_name"
    t.string   "type"
    t.boolean  "mirrorable"
    t.integer  "priority"
    t.string   "image"
    t.integer  "image_width"
    t.integer  "image_height"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "spotlightable"
    t.boolean  "disabled"
  end

  create_table "studio_sticker_packs", force: true do |t|
    t.integer "sticker_pack_id"
    t.integer "sort_order"
    t.integer "studio_id"
  end

  add_index "studio_sticker_packs", ["sticker_pack_id"], name: "index_studio_sticker_packs_on_sticker_pack_id", using: :btree
  add_index "studio_sticker_packs", ["studio_id"], name: "index_studio_sticker_packs_on_studio_id", using: :btree

  create_table "studios", force: true do |t|
    t.string   "name"
    t.string   "display_name"
    t.boolean  "disabled",                           default: true
    t.integer  "affiliate_id"
    t.integer  "contest_id"
    t.integer  "scene_id"
    t.text     "welcome_message"
    t.integer  "sticker_pack_id"
    t.datetime "starts_at"
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image"
    t.string   "icon"
    t.text     "getting_started_markdown"
    t.text     "getting_started_html"
    t.text     "help_html"
    t.text     "help_markdown"
    t.text     "stand_alone_studio_header_html"
    t.text     "stand_alone_studio_header_markdown"
  end

  add_index "studios", ["affiliate_id"], name: "index_studios_on_affiliate_id", using: :btree
  add_index "studios", ["contest_id"], name: "index_studios_on_contest_id", using: :btree
  add_index "studios", ["scene_id"], name: "index_studios_on_scene_id", using: :btree
  add_index "studios", ["sticker_pack_id"], name: "index_studios_on_sticker_pack_id", using: :btree

  create_table "surveys", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",                            null: false
    t.string   "uuid",                               null: false
    t.text     "thank_you_markdown"
    t.text     "thank_you_html"
    t.string   "redirect"
    t.string   "redirect_url"
    t.integer  "redirect_timeout"
    t.boolean  "thank_you_default",  default: false, null: false
    t.integer  "theme_id",           default: 1,     null: false
  end

  add_index "surveys", ["redirect"], name: "index_surveys_on_redirect", using: :btree
  add_index "surveys", ["user_id"], name: "index_surveys_on_user_id", using: :btree
  add_index "surveys", ["uuid"], name: "index_surveys_on_uuid", unique: true, using: :btree

  create_table "taggings", force: true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: true do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "targets", force: true do |t|
    t.boolean  "all_users"
    t.boolean  "all_followers"
    t.boolean  "all_groups"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.boolean  "all_communities"
    t.string   "type",            default: "ConsumerTarget"
    t.integer  "min_age"
    t.integer  "max_age"
    t.string   "gender"
  end

  add_index "targets", ["user_id"], name: "index_targets_on_user_id", using: :btree

  create_table "targets_users", force: true do |t|
    t.integer  "user_id"
    t.integer  "target_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "targets_users", ["target_id"], name: "index_targets_users_on_target_id", using: :btree
  add_index "targets_users", ["user_id"], name: "index_targets_users_on_user_id", using: :btree

  create_table "translations", force: true do |t|
    t.integer  "language_id"
    t.string   "key"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "translations", ["language_id"], name: "index_translations_on_language_id", using: :btree

  create_table "trends", force: true do |t|
    t.integer  "new_event_count"
    t.datetime "calculated_at"
    t.decimal  "filter_event_count", precision: 10, scale: 2
    t.decimal  "filter_minutes",     precision: 10, scale: 2
    t.decimal  "rate",               precision: 10, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_avatars", force: true do |t|
    t.string   "image"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                     default: ""
    t.string   "encrypted_password",        default: "",     null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",             default: 0,      null: false
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
    t.date     "birthdate"
    t.string   "gender"
    t.string   "company_name"
    t.integer  "feed_page",                 default: 0
    t.integer  "user_avatar_id"
    t.string   "type",                      default: "User"
    t.integer  "push_on_question_asked",    default: -1
    t.integer  "push_on_question_answered", default: -1
    t.boolean  "auto_feed",                 default: true
  end

  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["type"], name: "index_users_on_type", using: :btree
  add_index "users", ["user_avatar_id"], name: "index_users_on_user_avatar_id", using: :btree
  add_index "users", ["username"], name: "index_users_on_username", using: :btree

  create_table "users_roles", id: false, force: true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree

end
