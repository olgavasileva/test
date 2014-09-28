class Response < ActiveRecord::Base



  belongs_to :user
  belongs_to :question
  has_many :liked_comments, dependent: :destroy
  has_many :comment_likers, through: :liked_comments, source: :user
  has_many :contest_response_votes, dependent: :destroy

	validates :question, presence: true
  validates :comment, length: { maximum: 2000, allow_nil: true }

  scope :with_comment, -> { where("comment <> ''") } # comment not nil or blank

  after_create :record_analytics
  after_create :add_and_push_message

  def description
    "Override me!"
  end

  protected

    def record_analytics
      DailyAnalytic.increment! :responses, question.user
    end

    def add_and_push_message

      if !QuestionUpdated.exists?(:question_id => self.question.id)
        message = QuestionUpdated.new
      else
        message = QuestionUpdated.find_by_question_id(self.question_id)
      end


      message.user_id = self.question.user_id
      message.question_id = self.question_id
      message.response_count = self.question.response_count
      message.comment_count = self.question.comment_count
      message.share_count = self.question.share_count
      message.body = "You have #{message.response_count} responses to your question \" #{self.question.title}\""
      message.body = message.body + " and you have #{message.comment_count} comments" if self.comment

      message.created_at = Time.zone.now()
      message.read_at = nil
      message.completed_at = Time.zone.now() if self.question.targeting?


      message.save



      self.user.instances.each do |instance|
        next unless instance.push_token.present?

        APNS.send_notification(instance.push_token, :alert => 'Hello iPhone!', :badge => 0, :sound => 'default',
                                                                       :other => {:type => message.type,
                                                                                  :created_at => message.created_at,
                                                                                  :read_at => message.read_at,
                                                                                  :question_id => message.question_id,
                                                                                  :response_count => message.response_count,
                                                                                  :comment_count => message.comment_count,
                                                                                  :share_count => message.share_count,
                                                                                  :completed_at => message.completed_at
                                                                       })
      end

    end
end
