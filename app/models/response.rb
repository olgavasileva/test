class Response < ActiveRecord::Base
  belongs_to :user, class_name:"Respondent"
  belongs_to :question
  has_one :comment, as: :commentable, dependent: :destroy
  has_many :contest_response_votes, dependent: :destroy

  validates :user, presence: true
	validates :question, presence: true
  validate :comment_if_required

  validate :answer_is_unique, on: :create,
    unless: 'question.allow_multiple_answers_from_user'

  after_create :record_analytics
  after_create :add_and_push_message
  after_create :modify_question_score

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

    def add_and_push_message
      if !QuestionUpdated.exists?(:question_id => self.question.id)
        message = QuestionUpdated.new
      else
        message = QuestionUpdated.find_by_question_id(self.question_id)
      end

      asker = question.user

      message.user_id = asker.id
      message.question_id = question_id
      message.response_count = question.response_count
      message.comment_count = question.comment_count
      message.share_count = question.share_count
      message.body = "You have #{message.response_count} responses to your question \"#{question.title}\""
      message.body = message.body + " and you have #{message.comment_count} comments" if comment
      message.body = message.body + " and your question is completed" if question.targeting?

      message.created_at = Time.zone.now()
      message.read_at = nil
      message.completed_at = Time.zone.now() if question.targeting?

      message.save!

      asker.instances.where.not(push_token:nil).each do |instance|

        instance.push alert:'Someone responded to your question', badge:user.messages.count, sound:true, other: {
                                                                          type: message.type,
                                                                          created_at: message.created_at,
                                                                          read_at: message.read_at,
                                                                          question_id: message.question_id,
                                                                          response_count: message.response_count,
                                                                          comment_count: message.comment_count,
                                                                          share_count: message.share_count,
                                                                          completed_at: message.completed_at }
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
