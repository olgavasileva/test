class FeedItem < ActiveRecord::Base
  belongs_to :user
  belongs_to :question

  after_create :add_and_push_message
  def add_and_push_message


    message = QuestionTargeted.new

    question = self.question

    message.user_id = self.user_id
    message.question_id = question.question_id

    user_name = question.anonymous? ? "Someone" : question.user.username
    message.body = "#{user_name} has a question for you"

    message.save

    targeted_user.instances.each do |instance|
      next unless instance.push_token.present?

      instance.push alert:'Hello iPhone!', badge:0, sound:true, other: {:type => message.type,
                                                                        :created_at => message.created_at,
                                                                        :read_at => message.read_at,
                                                                        :question_id => message.question_id,
                                                                        :body => message.body }
    end

    # if !QuestionTargeted.exists?(:user_id => self.user_id)
    #   message = QuestionTargeted.new
    # else
    #   message = QuestionTargeted.find_by_user_id(self.user_id)
    # end
    #
    #
    # message.user_id = self.question.user_id
    # message.question_id = self.question_id
    #
    # question = self.question
    # user_name = question.anonymous? ? "Someone" : question.user.username
    # message.body = "#{user_name} has a question for you"
    #
    # message.save
    #
    #
    #
    # self.user.instances.each do |instance|
    #   next unless instance.push_token.present?
    #
    #   APNS.send_notification(instance.push_token, :alert => 'Hello iPhone!', :badge => 0, :sound => 'default',
    #                          :other => {:type => message.type,
    #                                     :created_at => message.created_at,
    #                                     :read_at => message.read_at,
    #                                     :question_id => message.question_id,
    #                                     :body => message.body
    #                          })
    # end

  end

end
