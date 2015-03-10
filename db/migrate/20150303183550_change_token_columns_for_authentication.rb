class ChangeTokenColumnsForAuthentication < ActiveRecord::Migration
  def up
    change_column :authentications, :token, :text
    change_column :authentications, :token_secret, :text
  end

  def down
    change_column :authentications, :token, :string
    change_column :authentications, :token_secret, :string
  end
end
