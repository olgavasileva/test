class CreateFollowerTargets < ActiveRecord::Migration
  def change
    create_table :follower_targets do |t|
      t.references :question, index: true
      t.references :follower, index: true

      t.timestamps
    end
  end
end
