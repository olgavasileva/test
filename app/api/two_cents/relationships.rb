require 'will_paginate/array'

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
      user = user_id.present? ? Respondent.find(user_id) : current_user

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
      user = user_id.present? ? Respondent.find(user_id) : current_user

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

    desc "Search for followable users"
    params do
      requires :auth_token, type: String, desc: "Obtain this from the instance's API."

      optional :search_text, type: String, desc: "Search text to match to users."
      optional :page, type: Integer, desc: "Page number, minimum 1. If left blank, responds with all."
      optional :per_page, type: Integer, default: 15, desc: "Number of users per page."
    end
    get 'followable' do
      # TODO: optimize
      # users = current_user.leaders.search(q: params[:search_text]).result
      # users += Respondent.search(q: params[:search_text]).result
      # users.uniq!

      query = Respondent.where.not(id: current_user.id).order(:username)

      if declared_params[:search_text]
        query = query.where("username like ?", "%#{params[:search_text]}%")
      end

      if params[:page]
        query = query.paginate(page: params[:page], per_page: params[:per_page])
      end

      query.map do |u|
        relationship = current_user.followership_relationships
          .where(leader_id: u.id)
          .first

        groups = relationship.try(:groups) || []

        {
          id: u.id,
          username: u.username,
          email: u.email,
          name: u.name,
          group_ids: groups.map(&:id),
          is_following: current_user.leaders.include?(u)
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
      user = Respondent.find(params[:user_id])

      if current_user.leaders.include? user
        fail! 400, "Already following user."
      end

      current_user.follow! user

      {}
    end

    # unfollow
    desc "Unfollow a user"
    params do
      requires :auth_token, type: String, desc: "Obtain this from the instance's API."

      requires :user_id, type: Integer, desc: "ID of user to unfollow."
    end
    post 'unfollow' do
      user = Respondent.find(params[:user_id])

      unless current_user.leaders.include? user
        fail! 400, "Not following user."
      end

      current_user.leaders.delete(user)

      {}
    end

    # Remove Follower
    desc "Removes a user from following you", notes: 'Returns a 204 Status on success'
    params do
      requires :auth_token, type: String, desc: "Obtain this from the instance's API."
      requires :user_id, type: Integer, desc: "ID of user to unfollow."
    end
    delete 'block' do
      validate_user!
      user = Respondent.find(params[:user_id])
      current_user.followers.delete(user)
      status 204
    end

    desc "Whether following a user"
    params do
      requires :auth_token, type: String, desc: "Obtain this from the instance's API."

      requires :user_id, type: Integer, desc: "ID of user to check whether following."
    end
    get 'is_following' do
      user = Respondent.find(params[:user_id])

      current_user.leaders.include? user
    end

    desc "Invite someone to become a user"
    params do
      requires :auth_token, type: String, desc: "Obtain this from the instance's API."

      requires :method, type: String, values: %w[email sms], desc: "How to send message to person."
      optional :email_address, type: String, desc: "Person's email address (for use with 'email' method)."
      optional :phone_number, type: String, desc: "Person's phone number (for use with 'sms' method)."
    end
    put 'summon' do
      validate_user!

      if params[:method] == 'email' && params[:email_address].blank?
        fail! 400, "`email_address` required for 'email' `method`"
      elsif params[:method] == 'sms' && params[:phone_number].blank?
        fail! 400, "`phone_number` required for 'sms' `method`"
      end

      message_setting = Setting.find_by_key!('share_app')
      url = Rails.application.routes.url_helpers.root_url
      message_text = "#{message_setting.value} #{url}"

      if params[:method] == 'email'
        send_email(params[:email_address], message_text)
      elsif params[:method] == 'sms'
        send_sms(params[:phone_number], message_text)
      end

      {}
    end

    desc "Invite multiple people to become users"
    params do
      requires :auth_token, type: String, desc: "Obtain this from the instance's API."

      optional :email_addresses, type: Array, default: [], desc: "People's email addresses."
      optional :phone_numbers, type: Array, default: [], desc: "People's phone numbers."
    end
    put 'summon_multiple' do
      validate_user!

      message_setting = Setting.find_by_key!('share_app')
      url = Rails.application.routes.url_helpers.root_path
      message_text = "#{message_setting.value} #{url}"

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
