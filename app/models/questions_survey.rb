class QuestionsSurvey < ActiveRecord::Base
  belongs_to :question
  belongs_to :survey

  acts_as_list scope: :survey

  after_save :update_question_state

  private
    def update_question_state
      question.update_attributes state: "survey_only"
    end
end
