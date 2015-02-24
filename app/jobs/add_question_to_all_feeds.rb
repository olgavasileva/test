class AddQuestionToAllFeeds
  @queue = :feed

  def self.perform question_id
    question = Question.eager_load(:user, :target).find_by(id: question_id)
    self.new.perform(question) if question
  end

  def perform(question)
    follower_ids = question.user.follower_ids.to_a
    leader_ids = question.user.leader_ids.to_a

    users_for_question(question).find_each do |user|
      next if user.feed_items.exists?(question_id: question.id)

      # Determine why we're adding this to the user's feed
      why = if follower_ids.include?(user.id)
        "leader"
      elsif leader_ids.include?(user.id)
        "follower"
      else
        "public"
      end

      user.feed_items << FeedItem.new(question:question, relevance:question.relevance_to(user), why: why)
      question.add_and_push_message user unless question.target.public?
    end
  end

  def users_for_question(question)
    table = FeedItem.table_name
    query = Respondent.joins <<-SQL.squish
      LEFT JOIN #{table}
        ON #{table}.`user_id` = `users`.`id`
        AND #{table}.`question_id` = #{question.id}
    SQL

    unless question.target.public?
      ids = question.target.community_member_ids
      ids += if question.target.all_followers?
        question.user.follower_ids
      else
        question.target.follower_ids
      end

      ids += if question.target.all_groups?
        question.user.group_member_ids
      else
        question.target.group_member_ids
      end

      query = query.where(id: ids)
    end

    join_atts = {FeedItem.table_name => {question_id: nil}}
    query.where(join_atts).uniq
  end
end
