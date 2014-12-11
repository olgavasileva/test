class QuestionObserver < ActiveRecord::Observer
  def before_destroy question
    FeedItem.question_deleted! question
  end

  def after_create question
    if question.public?
      User.all.each do |user|
        if user.wants_question? question
          user.feed_questions << question
          add_and_push_message user, question
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