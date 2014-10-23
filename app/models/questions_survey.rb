class QuestionsSurvey < ActiveRecord::Base
  belongs_to :question
  belongs_to :survey

  acts_as_list scope: :survey
end
