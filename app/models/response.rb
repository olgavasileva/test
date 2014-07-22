class Response < ActiveRecord::Base
  belongs_to :user
  belongs_to :question

	validates :question, presence: true
  validates :comment, length: { maximum: 140, allow_nil: true }
end
