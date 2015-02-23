class AddQuestionToAllFeeds
  @queue = :feed

  def self.perform question_id
    Respondent.find_each do |user|
      question = Question.find_by id:question_id

      if question
        item = user.feed_items.find_by question_id:question_id

        if item.nil?

          # Determine why we're adding this to the user's feed
          why = if user.leaders.pluck(:id).include?(question.user.id)
            "leader"
          elsif user.followers.pluck(:id).include?(question.user.id)
            "follower"
          else
            "public"
          end

          user.feed_items << FeedItem.new(question:question, relevance:question.relevance_to(user), why: why)
          question.add_and_push_message user unless why == "public"
        end
      end
    end
  end
end