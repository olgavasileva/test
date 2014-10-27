class AddFollowerIdToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :follower_id, :integer
  end
end
