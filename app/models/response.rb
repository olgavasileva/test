class Response < ActiveRecord::Base

  after_create :add_and_push_message

  belongs_to :user
  belongs_to :question
  has_many :liked_comments, dependent: :destroy
  has_many :comment_likers, through: :liked_comments, source: :user

	validates :question, presence: true
  validates :comment, length: { maximum: 2000, allow_nil: true }

  scope :with_comment, -> { where("comment <> ''") } # comment not nil or blank

  protected
    def add_and_push_message

      if !QuestionUpdated.exists?(:question_id => self.question.id)
        message = QuestionUpdated.new
      else
        message = QuestionUpdated.find_by_question_id(self.question_id)
      end

      message.user_id = self.user_id
      message.question_id = self.question_id
      message.response_count = self.question.response_count
      message.comment_count = self.question.comment_count
      message.share_count = self.question.share_count

      message.completed_at = Time.now() if self.question.targeting?

      message.save

      # device_token = '12121313'
      #
      # APNS.send_notification(device_token, :alert => 'Hello iPhone!', :badge => 1, :sound => 'default',
      #                        :other => {:type => message.type,
      #                                   :created_at => message.created_at,
      #                                   :read_at => message.read_at,
      #                                   :question_id => message.question_id,
      #                                   :response_count => message.response_count,
      #                                   :comment_count => message.comment_count,
      #                                   :share_count => message.share_count,
      #                                   :completed_at => message.completed_at})
    end
end
