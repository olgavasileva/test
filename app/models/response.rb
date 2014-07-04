class Response < ActiveRecord::Base
  belongs_to :user
  belongs_to :question

	validates :question, presence: true
end
