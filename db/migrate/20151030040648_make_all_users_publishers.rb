class MakeAllUsersPublishers < ActiveRecord::Migration
  def change
    User.all.find_each do |user|
      if user.roles.empty?
        user.roles << Role.publisher
        user.save
      end
    end
  end
end
