class AddTargetedReachToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :targeted_reach, :integer
  end
end
