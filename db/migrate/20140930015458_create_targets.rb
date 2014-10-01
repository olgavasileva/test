class CreateTargets < ActiveRecord::Migration
  def change
    create_table :targets do |t|
      t.boolean :all_users
      t.boolean :all_followers
      t.boolean :all_groups

      t.timestamps
    end
  end
end
