class Target < ActiveRecord::Base
  belongs_to :user, class_name: "Respondent"
  has_many :questions

  def apply_to_question question
  end
end
