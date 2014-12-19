class MoveAuthTokenToUser < ActiveRecord::Migration
  def up
    add_column :users, :auth_token, :string

    begin
      User.reset_column_information
      Instance.all.each {|instance| instance.user.update_attributes auth_token: instance.auth_token if instance.user}
    rescue Exception => e
    end

    remove_column :instances, :auth_token
  end

  def down
    add_column :instances, :auth_token, :string

    begin
      Instance.reset_column_information
      Instance.all.each {|instance| instance.update_attributes auth_token: instance.user.auth_token if instance.user}
    rescue Exception => e
    end

    remove_column :users, :auth_token
  end
end
