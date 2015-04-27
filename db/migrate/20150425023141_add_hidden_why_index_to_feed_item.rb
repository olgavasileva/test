class AddHiddenWhyIndexToFeedItem < ActiveRecord::Migration
  def change
    add_index :questions, [:state, :kind]
    # add_index :feed_items_v2, [:hidden, :why]
  end
end
