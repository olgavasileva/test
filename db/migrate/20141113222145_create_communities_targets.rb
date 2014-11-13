class CreateCommunitiesTargets < ActiveRecord::Migration
  def change
    create_table :communities_targets do |t|
      t.references :target, index: true
      t.references :community, index: true

      t.timestamps
    end
  end
end
