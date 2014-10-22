class CreateEnterpriseTargetsSegments < ActiveRecord::Migration
  def change
    create_table :enterprise_targets_segments do |t|
      t.references :enterprise_target, index: true
      t.references :segment, index: true

      t.timestamps
    end
  end
end
