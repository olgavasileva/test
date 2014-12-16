class ChangeTargetedToWhy < ActiveRecord::Migration
  def up
    add_column :feed_items_v2, :why, :string
    remove_column :feed_items_v2, :targeted
  end

  def down
    add_column :feed_items_v2, :targeted, :boolean, index: true
    remove_column :feed_items_v2, :why
  end
end
