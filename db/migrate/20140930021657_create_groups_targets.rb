class CreateGroupsTargets < ActiveRecord::Migration
  def change
    create_table :groups_targets do |t|
      t.references :group, index: true
      t.references :target, index: true

      t.timestamps
    end
  end
end
