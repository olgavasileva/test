class Pack < ActiveRecord::Base
	belongs_to :user, class_name: "Respondent"
	validates :user_id, presence: true
	validates :title, presence: true
	has_many :inclusions, dependent: :destroy
	has_many :questions, through: :inclusions

	def include_question!(question)
		self.inclusions.create!(question_id: question.id)
	end

	def disinclude_question!(question)
		self.inclusions.find_by(question_id: question.id).destroy!
	end

	def includer_of?(question)
		self.inclusions.find_by(question_id: question.id)
	end

	def as_json(options={})
		super(:include => [:user =>{:only => [:id, :username, :name]}], :only => [:id, :title, :created_at, :updated_at])
	end
end
