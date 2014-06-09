class CreateOwnerships < ActiveRecord::Migration
  def change
    create_table :ownerships do |t|
      t.integer :user_id
      t.integer :device_id
      t.string :remember_token

      t.timestamps
    end

    add_index :ownerships, :remember_token
    add_index :ownerships, :user_id
    add_index :ownerships, :device_id
    add_index :ownerships, [:user_id, :device_id], unique: true
  end
end
