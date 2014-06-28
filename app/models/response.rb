class Response < ActiveRecord::Base
  belongs_to :user
  belongs_to :question

	validates :user, presence: true
	validates :question, presence: true
end
