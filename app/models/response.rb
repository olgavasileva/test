class Response < ActiveRecord::Base
  belongs_to :user
  belongs_to :question
  has_many :liked_comments
  has_many :comment_likers, through: :liked_comments, source: :user

	validates :question, presence: true
  validates :comment, length: { maximum: 140, allow_nil: true }
end
