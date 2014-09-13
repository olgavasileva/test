class CreateGroupTargets < ActiveRecord::Migration
  def change
    create_table :group_targets do |t|
      t.references :question, index: true
      t.references :group, index: true

      t.timestamps
    end
  end
end
