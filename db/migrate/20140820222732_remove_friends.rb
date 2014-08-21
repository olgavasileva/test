class RemoveFriends < ActiveRecord::Migration
  def up
    drop_table :friendships
  end

  def down
    create_table :friendships do |t|
      t.integer  :user_id
      t.integer  :friend_id
      t.string   :status
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_index :friendships, :friend_id
    add_index :friendships, :user_id
    add_index :friendships, :user_id
  end
end
