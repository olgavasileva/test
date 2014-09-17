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

  def description
    "Override me!"
  end

  protected

    def record_analytics
      DailyAnalytic.increment! :responses, question.user
    end
end
