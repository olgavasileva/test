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
    put 'group'

    # update group
    desc "Update one of my groups"
    post 'group'

    # delete group
    desc "Delete one of my groups"
    delete 'group'

  end

end
