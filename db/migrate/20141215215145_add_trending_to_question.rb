class AddTrendingToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :trending_index, :integer, index: true, default: 0
    add_column :questions, :trending_multiplier, :integer, default: 1
  end
end
