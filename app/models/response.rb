class Response < ActiveRecord::Base

  after_create :add_and_push_message

  belongs_to :user
  belongs_to :question
  belongs_to :comment_parent, class_name: 'Response'
  has_many :liked_comments, dependent: :destroy
  has_many :comment_likers, through: :liked_comments, source: :user
  has_many :contest_response_votes, dependent: :destroy

	validates :question, presence: true
  validates :comment, length: { maximum: 2000, allow_nil: true }
  validate :comment_parent_shares_question

  scope :with_comment, -> { where("comment <> ''") } # comment not nil or blank

  after_create :record_analytics

  def description
    "Override me!"
  end

  def comment_children
    self.class.where(comment_parent_id: id)
  end

  protected

    def record_analytics
      DailyAnalytic.increment! :responses, question.user
    end

    def comment_parent_shares_question
      if comment_parent.present? && comment_parent.question != question
        errors.add(:comment_parent_id, "must belong to the same question.")
      end
    end

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

      APNS.host = 'gateway.push.apple.com'
      # gateway.sandbox.push.apple.com is default

      APNS.pem  = Rails.root + 'app/pem/crashmob_dev_push.pem'

      # this is the file you just created

      APNS.port = 2195

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
