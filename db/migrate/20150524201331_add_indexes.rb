class AddIndexes < ActiveRecord::Migration
  def change
    add_index :question_actions, [:type, :respondent_id]
  end
end
