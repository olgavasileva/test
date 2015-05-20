class RefactorTargets < ActiveRecord::Migration
  def up
    # add fields to :targets
    add_column :targets, :type, :string, default: "ConsumerTarget"
    add_column :targets, :min_age, :integer
    add_column :targets, :max_age, :integer
    add_column :targets, :gender, :string
    add_column :targets, :legacy_enterprise_target_id, :integer

    # move data from :enterprise_targets to :targets
    sql = []
    sql << "INSERT INTO targets (type, user_id, min_age, max_age, gender, created_at, updated_at, legacy_enterprise_target_id)"
    sql << "SELECT 'EnterpriseTarget', user_id, min_age, max_age, gender, created_at, updated_at, id"
    sql << "FROM enterprise_targets"
    ActiveRecord::Base.connection.execute sql.join(" ")

    # fix up enterprise_targets_segments.enterprise_target_id
    sql = "UPDATE enterprise_targets_segments ets, targets t SET ets.enterprise_target_id = t.id WHERE ets.enterprise_target_id = t.legacy_enterprise_target_id"
    ActiveRecord::Base.connection.execute sql

    # remove :enterprise_targets table
    drop_table :enterprise_targets

    # remove helper field
    remove_column :targets, :legacy_enterprise_target_id
  end

  def down
    # create :enterprise_targets table
    create_table :enterprise_targets do |t|
      t.references :user, index: true
      t.integer :min_age
      t.integer :max_age
      t.string :gender
      t.integer :legacy_target_id

      t.timestamps
    end

    # move data from :targets to :enterprise_targets
    sql = []
    sql << "INSERT INTO enterprise_targets (user_id, min_age, max_age, gender, created_at, updated_at, legacy_target_id)"
    sql << "SELECT user_id, min_age, max_age, gender, created_at, updated_at, id"
    sql << "FROM targets"
    sql << "WHERE type = 'EnterpriseTarget'"
    ActiveRecord::Base.connection.execute sql.join(" ")

    sql = "DELETE FROM targets WHERE type = 'EnterpriseTarget'"
    ActiveRecord::Base.connection.execute sql

    # fix up enterprise_targets_segments.enterprise_target_id
    sql = "UPDATE enterprise_targets_segments ets, enterprise_targets t SET ets.enterprise_target_id = t.id WHERE ets.enterprise_target_id = t.legacy_target_id"
    ActiveRecord::Base.connection.execute sql

    # remove fields from :targets
    remove_column :targets, :type
    remove_column :targets, :min_age
    remove_column :targets, :max_age
    remove_column :targets, :gender

    # remove helper field
    remove_column :enterprise_targets, :legacy_target_id
  end
end
