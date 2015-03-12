class ResponseNotificationSender
  @queue = :notification

  def self.perform(question_id)
    question = Question.find(question_id)
    self.new.perform(question)
  rescue ActiveRecord::RecordNotFound => e
  end

  def perform(question)
    user = question.user
    message = build_message(question)

    user.instances.where.not(push_token:nil).each do |instance|
      instance.push({
        alert:'Someone responded to your question',
        badge: user.messages.count,
        sound: true,
        other: {
          type: message.type,
          created_at: message.created_at,
          read_at: message.read_at,
          question_id: message.question_id,
          response_count: message.response_count,
          comment_count: message.comment_count,
          share_count: message.share_count,
          completed_at: message.completed_at
        }
      })
    end
  end

  def build_message(question)
    QuestionUpdated.where(question_id: question.id).first_or_initialize.tap do |m|
      m.user_id = question.user.id
      m.response_count = question.response_count
      m.comment_count = question.comment_count
      m.share_count = question.share_count
      m.read_at = nil

      now = Time.now
      m.created_at = now
      m.completed_at = now if question.targeting?

      body = "You have #{m.response_count} responses to your question \"#{question.title}\""
      body += " and you have #{m.comment_count} comments" if m.comment_count > 0
      body += " and your question is completed" if question.targeting?
      m.body = body
      m.save!
    end
  end
end
