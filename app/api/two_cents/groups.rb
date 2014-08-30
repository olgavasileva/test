class TwoCents::Groups < Grape::API
  resource :groups do

    # list groups
    desc "List my groups"
    get 'groups'

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