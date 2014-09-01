class Response < ActiveRecord::Base
  belongs_to :user
  belongs_to :question
  has_many :liked_comments, dependent: :destroy
  has_many :comment_likers, through: :liked_comments, source: :user

	validates :question, presence: true
  validates :comment, length: { maximum: 2000, allow_nil: true }
  scope :with_comment, -> { where("comment <> ''") } # comment not nil or blank
end
