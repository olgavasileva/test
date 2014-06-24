class TwoCents::Users < Grape::API
  resource :users do

    desc 'Register a new user', {
      notes: <<-END
      END
    }
    params do
      requires :username, type: String, regexp:User::VALID_USERNAME_REGEX
      requires :name, type: String, regexp:/\A.{1,50}\z/
      requires :email, type: String, regexp: /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,6}$.?/i, desc:'e.g. oscar@madisononline.com'
      requires :password, type: String
      requires :password_confirmation, type: String
      requires :udid, type: String
      requires :device_type, type: String
      requires :os_version, type: String
    end
    post 'register', http_codes:[
      [400, "1000 - Invalid params"],
      [404, "1001 - Record not found"],
      [500, "1002 - Server error"]
    ] do
      ActiveRecord::Base.transaction do
        user = User.create! declared_params.slice(:username, :name, :email, :password, :password_confirmation)
        device = Device.where(udid: declared_params[:udid]).first_or_create declared_params.slice(:device_type, :os_version)
        device.update_attributes! declared_params.slice(:device_type, :os_version)
        ownership = Ownership.find_by(device_id: device.id, user_id: user.id) || user.own!(device)

        {success:ownership}
      end
    end


    # Is this API used?  Seems like register is more appropriate
    desc "Create a new user - Is this API used?  Seems like register is more appropriate"
    params do
      requires :username, type: String, regexp:User::VALID_USERNAME_REGEX
      requires :name, type: String, regexp:/\A.{1,50}\z/
      requires :email, type: String, regexp: /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,6}$.?/i, desc:'e.g. oscar@madisononline.com'
      requires :password, type: String
      requires :password_confirmation, type: String
    end
    post do
      {success:User.create!(declared_params)}
    end


    desc 'Log in a user'
    params do
      optional :id, type: Integer
      requires :username, type: String, regexp:User::VALID_USERNAME_REGEX
      requires :password, type: String
      requires :udid, type: String
      requires :device_type, type: String
      requires :os_version, type: String
    end
    post ':id/login' do
      user = User.find_by(username: declared_params[:username].downcase)
      fail! 403, "forbidden: invalid username and password combination, access denied" unless user && user.authenticate(params[:user][:password])
      device = Device.find_by(udid: declared_params[:udid]) || Device.create!(declared_params.slice(:udid, :device_type, :os_version))
      device.update_attributes! declared_params.slice(:device_type, :os_version)
      ownership = Ownership.find_by(device_id: device.id, user_id: user.id)

      if !ownership
        user.own! device
        ownership = Ownership.find_by device_id: device.id, user_id: user.id
      else
        remember_token = User.new_remember_token
        ownership.update_attribute :remember_token, User.encrypt(remember_token)
      end

      {success: ownership}
    end



    desc "Return a list of users for the given 'page'"
    params do
      requires :udid, type: String
      requires :remember_token, type: String
      optional :id, type: Integer
      requires :page, type: Integer
    end
    post ':id/list_index' do
      authorize_user!

      {success:User.paginate(page:declared_params[:page])}
    end



    desc "Become friends with all other users"
    params do
      requires :udid, type: String
      requires :remember_token, type: String
      optional :id, type: Integer
    end
    post ':id/autofriend_all_users' do
      authorize_user!

      User.all.each do |user|
        unless user == current_user
          unless current_user.friends_with? user
            current_user.friend! user
          end

          unless user.friends_with? current_user
            user.friend! current_user
          end
        end
      end

      { success: { friendships: current_user.friendships } }
    end


    desc "Return the list of my friends"
    params do
      requires :udid, type: String
      requires :remember_token, type: String
      optional :id
    end
    post ':id/friends' do
      { success: { friends: current_user.friends } }
    end


    desc "Return a list of users the caller is following"
    params do
      requires :udid, type: String
      requires :remember_token, type: String
      optional :id, type: Integer
      requires :page, type: Integer
    end
    post ':id/following' do
      # Shouldn't this just use the current_user?
      user = User.find declared_params[:id]
      users = user.followed_users.paginate page: declared_params[:page]
      { success:users }
    end


    desc "Return a list of users following this user"
    params do
      requires :udid, type: String
      requires :remember_token, type: String
      requires :page, type: Integer
      optional :id, type: Integer
    end
    post ':id/followers' do
      user = User.find declared_params[:id]
      users = user.followers.paginate page: declared_params[:page]
      { success:users }
    end


    desc "Return a list of this user's devices"
    params do
      requires :udid, type: String
      requires :remember_token, type: String
      requires :page, type: Integer
      optional :id, type: Integer
    end
    post ':id/devices' do
      # TODO - is there any reason to accept :id param?
      user = User.find declared_params[:id]
      fail! "forbidden: user can only access its own devices, access denied", 403 unless user == current_user

      devices = current_user.devices.paginate page: declared_params[:page]
      { success:devices }
    end


    desc "Return a list of this user's microposts"
    params do
      requires :udid, type: String
      requires :remember_token, type: String
      requires :page, type: Integer
      optional :id, type: Integer
    end
    post ':id/microposts' do
      # TODO - is there any reason to accept :id param?
      user = User.find declared_params[:id]
      fail! "forbidden: user can only access its own devices, access denied", 403 unless user == current_user

      microposts = user.microposts.paginate page: declared_params[:page]
      { success:microposts }
    end


    desc "Follow the identified user"
    params do
      requires :udid, type: String
      requires :remember_token, type: String
      requires :id, type: Integer
    end
    post ':id/follow' do
      other_user = User.find declared_params[:id]

      if current_user != other_user
        current_user.follow!(other_user)
        fail! 500, "internal-server-error: user follow failed" unless current_user.following? other_user
      end

      {success: other_user}
    end


    desc "Stop following the identified user"
    params do
      requires :udid, type: String
      requires :remember_token, type: String
      requires :id, type: Integer
    end
    post ':id/unfollow' do
      other_user = User.find declared_params[:id]

      if current_user != other_user
        current_user.unfollow! other_user
        fali! 500, "internal-server-error: user unfollow failed" if current_user.following? other_user
      end

      {success:other_user}
    end
  end
end
