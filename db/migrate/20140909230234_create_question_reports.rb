class CreateQuestionReports < ActiveRecord::Migration
  def change
    create_table :question_reports do |t|
      t.references :question, index: true
      t.references :user, index: true
      t.text :reason

      t.timestamps
    end
  end
end
