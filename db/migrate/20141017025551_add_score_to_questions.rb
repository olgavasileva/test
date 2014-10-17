class AddScoreToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :score, :decimal, default: 0, precision: 5, scale: 2
  end
end
