class TwoCents::Communities < Grape::API
  resource :communities do
    helpers do
      params :auth do
        requires :auth_token, type: String, desc: "Obtain this from the instance's API."
      end

      params :id do
        requires :id, type: Integer, desc: "ID of community."
      end

      params :community do
        requires :name, type: String, desc: "Display name for community."
        optional :private, type: Boolean, default: false, desc: "Whether password is needed for new members."
        optional :password, type: String, desc: "Password for new members (private only)"
        optional :description, type: String
      end

      params :member do
        requires :user_id, type: Integer, desc: "ID of member user."
        requires :community_id, type: Integer, desc: "ID of community."
      end

      def serialize_community(c)
        {
          id: c.id,
          name: c.name
        }
      end

      def community_params
        params.to_h.slice *%w[name private password description]
      end
    end


    desc "Return owned communities."
    params do
      use :auth
    end
    get :as_owner do
      validate_user!

      current_user.communities.map do |c|
        serialize_community(c)
      end
    end

    desc "Return communities as member."
    params do
      use :auth
    end
    get :as_member do
      validate_user!

      current_user.membership_communities.map do |c|
        serialize_community(c)
      end
    end

    desc "Return communities as potential member."
    params do
      use :auth
    end
    get :as_potential_member do
      validate_user!

      user_communities = \
        current_user.communities + current_user.membership_communities

      Community.where.not(id: user_communities) do |c|
        serialize_community(c)
      end
    end

    desc "Create a community."
    params do
      use :auth
      use :community
    end
    post do
      validate_user!

      c = current_user.communities.create! community_params

      serialize_community(c)
    end

    desc "Update a community."
    params do
      use :auth
      use :id
      use :community
    end
    put do
      validate_user!

      c = current_user.communities.find(params[:id])
      c.update_attributes! community_params

      {}
    end

    desc "Delete a community."
    params do
      use :auth
      use :id
    end
    delete do
      validate_user!

      c = current_user.communities.find(params[:id])
      c.destroy!

      {}
    end

    desc "Create a member in a community."
    params do
      use :auth
      use :member
    end
    post :members do
      validate_user!

      c = current_user.communities.find(params[:community_id])
      u = User.find(params[:user_id])
      c.member_users << u

      {}
    end

    desc "Delete a member in a community."
    params do
      use :auth
      use :member
    end
    delete :members do
      validate_user!

      c = current_user.communities.find(params[:community_id])
      u = User.find(params[:user_id])
      fail! 400, "User is not a member." unless c.member_users.include? u
      c.member_users.delete(u)

      {}
    end
  end
end
