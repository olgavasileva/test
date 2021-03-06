class Sharing < ActiveRecord::Base
	belongs_to :sender, class_name: "Respondent"
	belongs_to :receiver, class_name: "Respondent"
	belongs_to :question

	validates :sender, presence: true
	validates :receiver, presence: true
	validates :question, presence: true
  after_create :modify_question_score

	def as_json(options={})
		super(:include => [:question => {:include => [:category, :choices, :user => {:only => [:id, :username, :name]}], :only => [:id, :created_at, :title, :info, :image_url, :question_type, ]}
			],
			:only => [:id, :sender_id, :receiver_id, :question_id, :created_at, :updated_at])
	end

  private

    def modify_question_score
      # TODO
    end
end
