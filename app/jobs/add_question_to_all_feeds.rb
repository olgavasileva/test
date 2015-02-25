class AddQuestionToAllFeeds
  @queue = :feed

  def self.perform question_id
    question = Question.eager_load(:user, :target).find_by(id: question_id)
    self.new.perform(question) if question
  end

  def perform question
    FeedItem::WHY.each do |why|
      users_for_question(question, why).find_each do |user|
        next if user.feed_items.exists?(question_id: question.id)

        user.feed_items << FeedItem.new(question:question, relevance:question.relevance_to(user), why: why)
        question.add_and_push_message user unless question.target.public?
      end
    end
  end

  def users_for_question question, why
    ids = case why
    when 'public'
      []
    when 'targeted'
      []
    when 'leader'
      []
    when 'follower'
      if question.target.all_followers?
        question.user.follower_ids
      else
        question.target.follower_ids
      end
    when 'group'
      if question.target.all_groups?
        question.user.group_member_ids
      else
        question.target.group_member_ids
      end
    when 'community'
      if question.target.all_communities?
        question.user.community_member_ids
      else
        question.target.community_member_ids
      end
    end


    table = FeedItem.table_name
    query = Respondent.joins <<-SQL.squish
      LEFT JOIN #{table}
        ON #{table}.`user_id` = `users`.`id`
        AND #{table}.`question_id` = #{question.id}
    SQL

    query = query.where(id: ids) unless question.target.public? && why == 'public'

    join_atts = {FeedItem.table_name => {question_id: nil}}
    query.where(join_atts).uniq
  end
end
