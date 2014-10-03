class DropOwnership < ActiveRecord::Migration
  def up
    drop_table :ownerships
  end

  def down
      create_table "ownerships" do |t|
      t.integer  "user_id"
      t.integer  "device_id"
      t.string   "remember_token"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "ownerships", ["device_id"]
    add_index "ownerships", ["remember_token"]
    add_index "ownerships", ["user_id", "device_id"]
    add_index "ownerships", ["user_id"]
  end
end
