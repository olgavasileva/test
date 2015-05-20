class QuestionAction < ActiveRecord::Base
  # This is a base class for STI (see QuestionActionSkip and QuesitonActionResponse)

  belongs_to :question
  belongs_to :respondent
end
