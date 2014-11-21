require 'will_paginate/array'

class TwoCents::Communities < Grape::API
  resource :communities do
    helpers do
      params :auth do
        requires :auth_token, type: String, desc: "Obtain this from the instance's API."
      end

      params :id do
        requires :id, type: Integer, desc: "ID of community."
      end

      params :user_index do
        optional :user_id, type: Integer, desc: "ID of user for results (defaults to current user's ID)"
      end

      params :search do
        optional :search_text, type: String, desc: "Search text to match to results."
      end

      params :pagination do
        optional :page, type: Integer, desc: "Page number, starting at 1. If left blank, responds with all results."
        optional :per_page, type: Integer, default: 15, desc: "Number of results per page."
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

      def specified_or_current_user
        User.find(params.fetch(:user_id, current_user.id))
      end

      def serialize_community(c)
        {
          id: c.id,
          name: c.name,
          member_count: c.members.count,
          description: c.description,
          private: c.private
        }
      end

      def community_params
        params.to_h.slice *%w[name private password description]
      end
    end


    desc "Return owned communities."
    params do
      use :auth
      use :user_index
    end
    get :as_owner do
      validate_user!

      specified_or_current_user.communities.map do |c|
        serialize_community(c)
      end
    end

    desc "Return communities as member."
    params do
      use :auth
      use :user_index
    end
    get :as_member do
      validate_user!

      specified_or_current_user.membership_communities.map do |c|
        serialize_community(c)
      end
    end

    desc "Return communities as potential member."
    params do
      use :auth
      use :search
      use :pagination
    end
    get :as_potential_member do
      validate_user!

      existing_communities =
        current_user.communities + current_user.membership_communities

      communities = Community
        .where.not(id: existing_communities)
        .search(name_cont: params[:search_text]).result
        .paginate(page: params[:page], per_page: params[:per_page])

      communities.map do |c|
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
      optional :password, type: String, desc: "Member password (private only)"
    end
    post :members do
      validate_user!

      c = Community.find(params[:community_id])

      unless c.public? || params[:password] == c.password
        fail! 400, "Incorrect password for private community."
      end

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

      c = Community.find(params[:community_id])
      u = User.find(params[:user_id])
      fail! 400, "User is not a member." unless c.member_users.include? u
      c.member_users.delete(u)

      {}
    end

    desc "Invite multiple people to join"
    params do
      requires :auth_token, type: String, desc: "Obtain this from the instance's API."

      requires :community_id, type: Integer, desc: "ID of community to invite to."
      optional :email_addresses, type: Array, default: [], desc: "People's email addresses."
      optional :phone_numbers, type: Array, default: [], desc: "People's phone numbers."
    end
    put 'summon_multiple' do
      validate_user!

      community = Community.find(params[:community_id])

      if community.private?
        message_setting = Setting.find_by_key('share_community_private')
      else
        message_setting = Setting.find_by_key('share_community_public')
      end
      url = Rails.application.routes.url_helpers.user_url(current_user, tab: 'communities')
      message_text = message_setting.value
      message_text.gsub!('%name%', community.name)
      message_text.gsub!('%password%', community.password)
      message_text = "#{message_text} #{url}"

      params[:email_addresses].each do |email_address|
        send_email(email_address, message_text)
      end

      params[:phone_numbers].each do |phone_num|
        send_sms(phone_num, message_text)
      end

      {}
    end
  end
end
