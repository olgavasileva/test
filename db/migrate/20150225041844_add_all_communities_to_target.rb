class AddAllCommunitiesToTarget < ActiveRecord::Migration
  def change
    add_column :targets, :all_communities, :boolean
  end
end
