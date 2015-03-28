class DeprecateOldViewAndStartCount < ActiveRecord::Migration
  def up
    rename_column :questions, :start_count, :legacy_start_count
    rename_column :questions, :view_count, :legacy_view_count
    add_column :questions, :view_count, :integer
  end

  def down
    remove_column :questions, :view_count
    rename_column :questions, :legacy_start_count, :start_count
    rename_column :questions, :legacy_view_count, :view_count
  end
end
