class AddProviderAndVersionToDemographic < ActiveRecord::Migration
  def change
    add_column :demographics, :data_provider, :string
    add_column :demographics, :data_version, :string
  end
end
