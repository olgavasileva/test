class AddCurrentlyTargetableToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :currently_targetable, :boolean, default: true
  end
end
