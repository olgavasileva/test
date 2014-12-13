class AddTargetedTofeedItemsV2 < ActiveRecord::Migration
  def change
    add_column :feed_items_v2, :targeted, :boolean, index: true
  end
end
