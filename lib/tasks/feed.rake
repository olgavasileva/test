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
  task migrate: [:remove_indexes, :delete_unhidden_public, :actions, :targeted]

  task remove_indexes: :environment do
    ActiveRecord::Base.connection.execute "ALTER TABLE `feed_items_v2` DROP INDEX `index_feed_items_v2_on_why`"
    ActiveRecord::Base.connection.execute "ALTER TABLE `feed_items_v2` DROP INDEX `idx2`"
    ActiveRecord::Base.connection.execute "ALTER TABLE `feed_items_v2` DROP INDEX `idx3`"
    ActiveRecord::Base.connection.execute "ALTER TABLE `feed_items_v2` DROP INDEX `idx5`"
    ActiveRecord::Base.connection.execute "ALTER TABLE `feed_items_v2` DROP INDEX `index_feed_items_v2_on_question_id`"
  end

  task delete_unhidden_public: :environment do
    ActiveRecord::Base.connection.execute "DELETE FROM feed_items_v2 WHERE hidden = 0 AND why = 'public'"
  end


  task actions: :environment do
    sql = []
    sql << "INSERT INTO question_actions (type, question_id, respondent_id, created_at, updated_at)"
    sql << "SELECT (CASE WHEN feed_items_v2.hidden_reason = 'skipped' THEN 'QuestionActionSkip' ELSE 'QuestionActionResponse' END), question_id, user_id, hidden_at, hidden_at"
    sql << "FROM feed_items_v2"
    sql << "WHERE feed_items_v2.hidden = 1 AND feed_items_v2.hidden_reason IN ('answered','skipped')"
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
