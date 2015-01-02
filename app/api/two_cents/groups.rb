class TwoCents::Groups < Grape::API
  resource :groups do

    # list groups
    desc "List my groups"
    params do
      requires :auth_token, type: String, desc: "Obtain this from the instance's API."
    end
    get 'groups' do
      validate_user!

      current_user.groups.map do |g|
        {
          id: g.id,
          name: g.name,
          member_count: g.members.count
        }
      end
    end

    # add group
    desc "Add a group"
    params do
      requires :auth_token, type: String, desc: "Obtain this from the instance's API."

      requires :name, type: String, desc: "Name for group."
    end
    post 'group' do
      validate_user!

      group = Group.new(user: current_user, name: params[:name])

      fail! 400, group.errors.full_messages.first unless group.save

      {
        id: group.id,
        name: group.name
      }
    end

    # update group
    desc "Update one of my groups"
    params do
      requires :auth_token, type: String, desc: "Obtain this from the instance's API."

      requires :id, type: Integer, desc: "ID for group."
      requires :name, type: String, desc: "New name for group."
    end
    put 'group' do
      validate_user!

      group = Group.find_by_id(params[:id])
      fail! 400, "Couldn't find group" unless group.present?
      fail! 400, "Group does not belong to user" if group.user != current_user

      group.update_attributes(name: params[:name])
      fail! 400, group.errors.full_messages.first unless group.save

      {}
    end

    # delete group
    desc "Delete one of my groups"
    params do
      requires :auth_token, type: String, desc: "Obtain this from the instance's API."

      requires :id, type: Integer, desc: "ID for group."
    end
    delete 'group' do
      validate_user!

      group = Group.find_by_id(params[:id])
      fail! 400, "Couldn't find group" unless group.present?
      fail! 400, "Group does not belong to user" if group.user != current_user

      group.destroy
      fail! 400, group.errors.full_messages.first unless group.save

      {}
    end

    # add follower to group
    desc "Add a follower to one of my groups"
    params do
      requires :auth_token, type: String, desc: "Obtain this from the instance's API."

      requires :id, type: Integer, desc: "ID for group."
      requires :user_id, type: Integer, desc: "ID for user to add to group."
    end
    put 'add_user' do
      validate_user!

      group = Group.find_by_id(params[:id])
      fail! 400, "Couldn't find group" unless group.present?
      fail! 400, "Group does not belong to user" if group.user != current_user

      user = Respondent.find_by_id(params[:user_id])
      fail! 400, "Couldn't find user" unless user.present?

      member = GroupMember.new(user_id: user.id, group_id: group.id)
      fail! 400, member.errors.full_messages.first unless member.save

      {}
    end

    # remove follower from group
    desc "Remove a follower from one of my groups"
    params do
      requires :auth_token, type: String, desc: "Obtain this from the instance's API."

      requires :id, type: Integer, desc: "ID for group."
      requires :user_id, type: Integer, desc: "ID for user to remove from group."
    end
    put 'remove_user' do
      validate_user!

      group = Group.find_by_id(params[:id])
      fail! 400, "Couldn't find group" unless group.present?
      fail! 400, "Group does not belong to user" if group.user != current_user

      user = Respondent.find_by_id(params[:user_id])
      fail! 400, "Couldn't find user" unless user.present?

      member = GroupMember.where(user_id: user.id, group_id: group.id).first
      fail! 400, "User is not part of group" unless member.present?
      fail! 400, member.errors.full_messages.first unless member.destroy!

      {}
    end
  end

end
