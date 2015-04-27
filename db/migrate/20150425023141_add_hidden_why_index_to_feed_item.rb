class AddHiddenWhyIndexToFeedItem < ActiveRecord::Migration
  def change
    add_index :feed_items_v2, [:hidden, :why]
    add_index :questions, [:state, :kind]
  end
end
