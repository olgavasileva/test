class AddWhyIndexToFeedItems < ActiveRecord::Migration
  def change
    add_index :feed_items_v2, :why
  end
end
