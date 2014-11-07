class AddUserAvatarIdToUsers < ActiveRecord::Migration
  def change
    add_reference :users, :user_avatar, index: true
  end
end
