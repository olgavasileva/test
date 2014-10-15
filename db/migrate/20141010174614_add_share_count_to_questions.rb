class AddShareCountToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :share_count, :integer
  end
end
