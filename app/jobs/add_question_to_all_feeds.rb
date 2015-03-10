class AddQuestionToAllFeeds
  @queue = :feed

  def self.perform question_id
    question = Question.eager_load(:user, :target).find_by(id: question_id)
    self.new.perform(question) if question
  end

  def perform question
    FeedItem::WHY.each do |why|
      users_for_question(question, why).find_each do |user|
        unless user.feed_items.exists?(question_id: question.id)
          user.feed_items << FeedItem.new(question:question, relevance:question.relevance_to(user), why: why)
          question.add_and_push_message user unless question.target.public?
        end
      end
    end
  end

  # Return an active record relation of users who should get this question in their feed.
  # No attempt is made here to exclude users who already have the question in their feed.
  def users_for_question question, why
    case why
    when 'public'
      question.target.public? ? Respondent.all : Respondent.none
    when 'targeted'
      Respondent.none
    when 'leader'
      Respondent.none
    when 'follower'
      if question.target.all_followers?
        question.user.followers
      else
        question.target.followers
      end
    when 'group'
      if question.target.all_groups?
        question.user.group_members
      else
        question.target.group_members
      end
    when 'community'
      if question.target.all_communities?
        question.user.fellow_community_members
      else
        question.target.community_members
      end
    end
  end
end
