class AddAllowMultipleAnswersToQuestions < ActiveRecord::Migration
  def change
    change_table :questions do |t|
      t.boolean :allow_multiple_answers_from_user, default: false
    end
  end
end
