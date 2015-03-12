class DropUnnecessaryIndexesOnFeedItems < ActiveRecord::Migration
  def up
    remove_index :feed_items_v2, name: 'idx1'
    remove_index :feed_items_v2, name: 'idx4'
    remove_index :feed_items_v2, name: 'index_feed_items_v2_on_user_id'
  end

  def down
    add_index :feed_items_v2, [:hidden, :hidden_reason], name: "idx1"
    add_index :feed_items_v2, [:user_id, :hidden, :hidden_reason], name: 'idx4'
    add_index :feed_items_v2, [:user_id], name: 'index_feed_items_v2_on_user_id'
  end
end
