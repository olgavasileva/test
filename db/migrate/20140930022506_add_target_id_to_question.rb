class AddTargetIdToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :target_id, :integer, index: true
  end
end
