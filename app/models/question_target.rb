class QuestionTarget < ActiveRecord::Base
  belongs_to :respondent  # A targeted user for this question
  belongs_to :question    # The question that was targeted to the respondent
  belongs_to :target      # Target criteria that caused this record
end
