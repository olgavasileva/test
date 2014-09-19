class AddDataFieldsToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :response_count, :integer, default: 0
    add_column :messages, :comment_count, :integer, default: 0
    add_column :messages, :share_count, :integer, default: 0
    add_column :messages, :completed_at, :datetime
  end
end
