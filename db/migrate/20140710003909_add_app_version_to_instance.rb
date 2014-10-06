class AddAppVersionToInstance < ActiveRecord::Migration
  def change
    add_column :instances, :app_version, :string
  end
end
