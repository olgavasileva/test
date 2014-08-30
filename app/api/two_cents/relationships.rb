class TwoCents::Relationships < Grape::API
  resource :relationships do

    # followers
    desc "List users following us"
    get 'followers'

    # following
    desc "List users being followed"
    get 'following'

    # follow
    desc "Follow a user"
    post 'follow'

    # unfollow
    desc "Unfollow a user"
    post 'unfollow'

  end
end