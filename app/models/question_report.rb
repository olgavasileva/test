class QuestionReport < ActiveRecord::Base
  belongs_to :question
  belongs_to :user, class_name: "Respondent"

  validates :question, presence: true
  validates :user, presence: true
  validates :reason, presence: true
end
