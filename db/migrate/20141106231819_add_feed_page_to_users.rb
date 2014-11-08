class AddFeedPageToUsers < ActiveRecord::Migration
  def change
    add_column :users, :feed_page, :integer, default: 0
  end
end
