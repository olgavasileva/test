class AddStartCountToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :start_count, :integer
  end
end
