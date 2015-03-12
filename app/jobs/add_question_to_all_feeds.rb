class AddQuestionToAllFeeds
  @queue = :question

  def self.perform question_id
    benchmark = Benchmark.measure do
      question = Question.eager_load(:user, :target).find_by(id: question_id)
      self.new.perform(question) if question
    end

    Rails.logger.info "AddQuestionToAllFeeds #{Figaro.env['MAX_QUESTIONS_FOR_NEW_RESPONDENT']}: #{benchmark}"
  end

  def perform question
    FeedItem::WHY.each do |why|
      users_for_question(question, why).find_in_batches do |users|
        items = []
        users.each do |user|
          unless user.feed_items.exists?(question_id: question.id)
            items << FeedItem.new(user: user, question: question, relevance: question.relevance_to(user), why: why)
          end
        end

        # Batch import
        FeedItem.import items

        # Once the question is in their feed, push the message to each user (if it's not a public question)
        users.each {|user| question.add_and_push_message user} unless question.target.public?
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
