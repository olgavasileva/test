class MoveAuthTokenBackToInstance < ActiveRecord::Migration
  def up
    add_column :instances, :auth_token, :string

    execute "UPDATE instances i, users u SET i.auth_token=u.auth_token WHERE u.id=i.user_id"

    remove_column :users, :auth_token
  end

  def down
    add_column :users, :auth_token, :string

    execute "UPDATE users u, instances i SET u.auth_token=i.auth_token WHERE i.user_id=u.id"

    remove_column :instances, :auth_token
  end
end
