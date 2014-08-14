class CreateFeeds < ActiveRecord::Migration
  def change
    create_table :feed_items do |t|
      t.references :user, index: true
      t.references :question, index: true
      t.string :reason

      t.timestamps
    end
  end
end
