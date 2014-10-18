class AddSpecialToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :special, :boolean, default: false
  end
end
