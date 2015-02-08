class Response < ActiveRecord::Base
  belongs_to :user, class_name:"Respondent"
  belongs_to :question
  has_one :comment, as: :commentable, dependent: :destroy
  has_many :contest_response_votes, dependent: :destroy

  validates :user, presence: true
	validates :question, presence: true
  validate :comment_if_required

  after_create :record_analytics
  after_create :modify_question_score
  after_commit :calculate_response_notification, on: :create

  accepts_nested_attributes_for :comment, reject_if: proc { |attributes| attributes['body'].blank? }

  def description
    "Override me!"
  end

  def csv_data
    ["Override me!"]
  end

  protected

    def record_analytics
      DailyAnalytic.increment! :responses, question.user
    end

    def calculate_response_notification
      if question.notifiable?
        question.update_attribute(:notifying, true)
        Resque.enqueue(ResponseNotificationCalculator, question.id)
      end
    end

    def modify_question_score
      question.increment! :score, comment.present? ? 1.5 : 1.0
    end

    def comment_if_required
      if question.require_comment?
        errors.add(:comments, "A comment is required") unless comment.present?
      end
    end
end
