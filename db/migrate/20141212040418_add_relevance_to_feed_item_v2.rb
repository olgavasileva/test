class AddRelevanceToFeedItemV2 < ActiveRecord::Migration
  def change
    add_column :feed_items_v2, :relevance, :integer, default: 0, index: true
  end
end
