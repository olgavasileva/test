class CreateInstances < ActiveRecord::Migration
  def change
    create_table :instances do |t|
      t.string :uuid
      t.references :device, index: true
      t.references :user, index: true
      t.string :push_app_name
      t.string :push_environment
      t.string :push_token
      t.integer :launch_count
      t.string :auth_token

      t.timestamps
    end
  end
end
