class AddMissingValueFieldsToQuestions < ActiveRecord::Migration
  def change
  	add_column :questions, :min_value, :integer
  	add_column :questions, :max_value, :integer
  	add_column :questions, :interval, :integer
  	add_column :questions, :units, :string
  end
end
