class Friendship < ActiveRecord::Base
	belongs_to :user, class_name: "Respondent"
	belongs_to :friend, class_name: "Respondent"
	validates :user_id, presence: true
	validates :friend_id, presence: true
end
