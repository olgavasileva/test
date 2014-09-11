class AddTargetingToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :target_all, :boolean, default: false
    add_column :questions, :target_all_followers, :boolean, default: false
    add_column :questions, :target_all_groups, :boolean, default: false
  end
end
