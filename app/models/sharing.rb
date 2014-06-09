class Sharing < ActiveRecord::Base
	belongs_to :sender, class_name: "User"
	belongs_to :receiver, class_name: "User"
	belongs_to :question

	validates :sender_id, presence: true
	validates :receiver_id, presence: true
	validates :question_id, presence: true

	def as_json(options={})
		super(:include => [:question => {:include => [:category, :choices, :user => {:only => [:id, :username, :name]}], :only => [:id, :created_at, :title, :info, :image_url, :question_type, ]}
			], 
			:only => [:id, :sender_id, :receiver_id, :question_id, :created_at, :updated_at])
	end
end
