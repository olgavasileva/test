class AddAutoFeedToUser < ActiveRecord::Migration
  def change
    add_column :users, :auto_feed, :boolean, default: true
  end
end
