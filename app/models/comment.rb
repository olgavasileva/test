class Comment < ActiveRecord::Base
	belongs_to :user
	belongs_to :question

	validates :user_id, presence: true
	validates :question, presence: true
	validates :content, presence: true, length: { maximum: 140 }
end
