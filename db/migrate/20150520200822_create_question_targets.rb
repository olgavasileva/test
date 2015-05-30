class CreateQuestionTargets < ActiveRecord::Migration
  def change
    create_table :question_targets do |t|
      t.references :respondent, index: true
      t.references :question, index: true
      t.references :target, index: true
      t.integer :relevance, default: 0
      t.timestamps
    end
  end
end
