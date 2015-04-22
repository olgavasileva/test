class Response < ActiveRecord::Base
  belongs_to :user, class_name:"Respondent"
  belongs_to :question
  has_one :comment, as: :commentable, dependent: :destroy
  has_many :contest_response_votes, dependent: :destroy
  has_many :demographics, through: :user
  has_one :demographic_summary, through: :user

  validates :user, presence: true
	validates :question, presence: true
  validates :source, inclusion: {in: %w(web embeddable ios android), allow_nil: true}
  validate :comment_if_required

  # validate :answer_is_unique, on: :create, unless: 'question.allow_multiple_answers_from_user'

  after_create :record_analytics
  after_create :modify_question_score
  after_commit :calculate_response_notification, on: :create

  # Roll our own counter cache updating because we need recent_responses_count to be writable so we can keep a rolling count
  after_create { Question.increment_counter :recent_responses_count, question_id }
  before_destroy { Question.decrement_counter :recent_responses_count, question_id }

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

    def answer_is_unique
      if Response.where(user_id: user_id, question_id: question_id).exists?
        errors.add(:base, 'User has already answered this question')
      end
    end
end
