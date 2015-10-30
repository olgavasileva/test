class MakeAllUsersPublishers < ActiveRecord::Migration
  def change
    Respondent.where.not(type: 'Anonymous').find_each do |user|
      if user.roles.empty?
        user.roles << Role.publisher
        user.save
      end
    end
  end
end
