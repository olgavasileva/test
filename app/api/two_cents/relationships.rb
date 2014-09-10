class TwoCents::Relationships < Grape::API
  resource :relationships do

    # followers
    desc "List users following us"
    params do
      requires :auth_token, type: String, desc: "Obtain this from the instance's API."

      optional :user_id, type: Integer, desc: "User ID. Defaults to logged in user's ID."
      optional :page, type: Integer, desc: "Page number, minimum 1. If left blank, responds with all."
      optional :per_page, type: Integer, default: 15, desc: "Number of followers per page."
    end
    get 'followers' do
      user_id = params[:user_id]
      user = user_id.present? ? User.find(user_id) : current_user

      followers = user.followers

      if params[:page]
        followers = followers.paginate(page: params[:page],
                                       per_page: params[:per_page])
      end

      followers.map do |f|
        relationship = f.followership_relationships.where(leader_id: user).first

        {
          id: f.id,
          username: f.username,
          email: f.email,
          name: f.name,
          group_ids: relationship.groups.map(&:id)
        }
      end
    end

    # following
    desc "List users being followed"
    params do
      requires :auth_token, type: String, desc: "Obtain this from the instance's API."

      optional :user_id, type: Integer, desc: "User ID. Defaults to logged in user's ID."
      optional :page, type: Integer, desc: "Page number, minimum 1. If left blank, responds with all."
      optional :per_page, type: Integer, default: 15, desc: "Number of users per page."
    end
    get 'following' do
      user_id = params[:user_id]
      user = user_id.present? ? User.find(user_id) : current_user

      leaders = user.leaders

      if params[:page]
        leaders = leaders.paginate(page: params[:page],
                                   per_page: params[:per_page])
      end

      leaders.map do |l|
        relationship = l.leadership_relationships.where(follower_id: user).first

        {
          id: l.id,
          username: l.username,
          email: l.email,
          name: l.name,
          group_ids: relationship.groups.map(&:id)
        }
      end
    end

    # follow
    desc "Follow a user"
    params do
      requires :auth_token, type: String, desc: "Obtain this from the instance's API."

      requires :user_id, type: Integer, desc: "ID of user to follow."
    end
    post 'follow' do
      user = User.find(params[:user_id])

      if current_user.leaders.include? user
        fail! 400, "Already following user."
      end

      current_user.leaders << user

      {}
    end

    # unfollow
    desc "Unfollow a user"
    params do
      requires :auth_token, type: String, desc: "Obtain this from the instance's API."

      requires :user_id, type: Integer, desc: "ID of user to unfollow."
    end
    post 'unfollow' do
      user = User.find(params[:user_id])

      unless current_user.leaders.include? user
        fail! 400, "Not following user."
      end

      current_user.leaders.delete(user)

      {}
    end

  end
end
