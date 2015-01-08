class QuestionObserver < ActiveRecord::Observer
  def before_destroy question
    FeedItem.question_deleted! question
  end

  def after_save question
    if question.public? && question.state_was != 'active' && question.state == 'active'
      Respondent.all.each do |user|
        item = user.feed_items.find_by question_id:question
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
          add_and_push_message user, question unless why == "public"
        end
      end
    end
  end


  def add_and_push_message(user, question)

    message = QuestionTargeted.new

    message.user_id = user.id
    message.question_id = question.id

    user_name = question.anonymous? ? "Someone" : question.user.username
    message.body = "#{user_name} has a question for you"

    message.save

    user.instances.where.not(push_token: nil).each do |instance|

      instance.push alert: message.body,
                    badge: user.messages.count,
                    sound: true,
                    other: {  type: message.type,
                              created_at: message.created_at,
                              read_at: message.read_at,
                              question_id: message.question_id,
                              body: message.body }
    end
  end

end