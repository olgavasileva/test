class CreateQuestionsSurveys < ActiveRecord::Migration
  def change
    create_table :questions_surveys do |t|
      t.references :question, index: true
      t.references :survey, index: true
      t.integer :position

      t.timestamps
    end
  end
end
