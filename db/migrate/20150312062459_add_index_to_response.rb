class AddIndexToResponse < ActiveRecord::Migration
  def change
    add_index :responses, [:type, :question_id]
    add_index :users, :username
    add_index :questions, :type
  end
end
