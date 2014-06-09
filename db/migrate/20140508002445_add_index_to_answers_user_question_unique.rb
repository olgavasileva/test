class AddIndexToAnswersUserQuestionUnique < ActiveRecord::Migration
  def change
  	add_index :answers, [:user_id, :question_id], unique: true
  end
end
