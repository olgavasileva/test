class CreateEnterpriseTargets < ActiveRecord::Migration
  def change
    create_table :enterprise_targets do |t|
      t.references :user, index: true
      t.integer :min_age
      t.integer :max_age
      t.string :gender

      t.timestamps
    end
  end
end
