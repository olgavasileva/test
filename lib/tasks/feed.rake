  # create_table "feed_items_v2", force: true do |t|
  #   t.integer  "user_id"
  #   t.integer  "question_id"
  #   t.datetime "published_at"
  #   t.datetime "hidden_at"
  #   t.boolean  "hidden"
  #   t.string   "hidden_reason"
  #   t.datetime "created_at"
  #   t.datetime "updated_at"
  #   t.integer  "relevance",     default: 0
  #   t.string   "why"
  # end

    # create_table :question_targets do |t|
    #   t.references :respondent, index: true
    #   t.references :question, index: true
    #   t.references :target, index: true
    #   t.integer :relevance, default: 0
    #   t.timestamps
    # end

    # create_table :question_actions do |t|
    #   t.string :type
    #   t.references :question, index: true
    #   t.references :respondent, index: true

    #   t.timestamps
    # end

namespace :feed do
  desc "Move from feedv2 to new faster model"
  task migrate: [:skipped, :answered, :targeted]

  task skipped: :environment do
    sql = []
    sql << "INSERT INTO question_actions (type, question_id, respondent_id, created_at, updated_at)"
    sql << "SELECT 'QuestionActionSkip', question_id, user_id, hidden_at, hidden_at"
    sql << "FROM feed_items_v2"
    sql << "WHERE feed_items_v2.hidden = 1 AND feed_items_v2.hidden_reason = 'skipped'"
    ActiveRecord::Base.connection.execute sql.join(" ")
  end

  task answered: :environment do
    sql = []
    sql << "INSERT INTO question_actions (type, question_id, respondent_id, created_at, updated_at)"
    sql << "SELECT 'QuestionActionResponse', question_id, user_id, hidden_at, hidden_at"
    sql << "FROM feed_items_v2"
    sql << "WHERE feed_items_v2.hidden = 1 AND feed_items_v2.hidden_reason = 'answered'"
    ActiveRecord::Base.connection.execute sql.join(" ")
  end

  task targeted: :environment do
    sql = []
    sql << "INSERT INTO question_targets (question_id, respondent_id, relevance, created_at, updated_at)"
    sql << "SELECT question_id, user_id, relevance, published_at, published_at"
    sql << "FROM feed_items_v2"
    sql << "WHERE feed_items_v2.why != 'public'"
    ActiveRecord::Base.connection.execute sql.join(" ")
  end
end
