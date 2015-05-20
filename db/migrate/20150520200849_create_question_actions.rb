class CreateQuestionActions < ActiveRecord::Migration
  def change
    create_table :question_actions do |t|
      t.string :type
      t.references :question, index: true
      t.references :respondent, index: true

      t.timestamps
    end
  end
end
