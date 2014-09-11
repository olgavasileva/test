class DropMicroposts < ActiveRecord::Migration
  def up
    drop_table :microposts
  end

  def down
    create_table :microposts do |t|
      t.string   :content
      t.integer  :user_id
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_index :microposts, [:user_id, :created_at]
  end
end
