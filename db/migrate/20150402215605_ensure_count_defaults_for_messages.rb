class EnsureCountDefaultsForMessages < ActiveRecord::Migration
  def up
    change_column :messages, :response_count, :integer, default: 0
    change_column :messages, :comment_count, :integer, default: 0
    change_column :messages, :share_count, :integer, default: 0
  end

  def down
  end
end
