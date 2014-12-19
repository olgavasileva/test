class AddDisableQuestionControlToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :disable_question_controls, :boolean, default: false
  end
end
