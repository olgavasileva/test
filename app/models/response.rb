class Response < ActiveRecord::Base
	belongs_to :answer
	belongs_to :choice

	validates :answer_id, presence: true
	validates :choice_id, presence: true
end
