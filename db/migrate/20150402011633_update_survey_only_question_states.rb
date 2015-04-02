class UpdateSurveyOnlyQuestionStates < ActiveRecord::Migration
  def up
    say_with_time "Setting all first survey questions as :active" do
      firsts = QuestionsSurvey.where(position: 1).select(:question_id)
      Question.where(id: firsts).update_all(state: 'active')
    end

    say_with_time "Setting all non-first survey questions as :survey_only" do
      others = QuestionsSurvey.where.not(position: 1).select(:question_id)
      Question.where(id: others)
        .where.not(state: 'pending')
        .update_all(state: 'survey_only')
    end
  end

  def down
  end
end
