class TwoCents::Users < Grape::API
  resource :users do

    desc 'Register a new user', {
      notes: <<-END
        Returns an ownership record.
        Use the remember_token and the udid in other API calls to identify the authenticity of this user.
        The remember_token should be stored securely on the device - it is equivalent to a password.

        #### Example response
            {
              "id": 8,
              "remember_token": "58f1218d6b26fa563401efee2d5208061dee8de5",
              "user": {
                "id": 9,
                "username": "troy4",
                "name": "troy4"
              }
            }

      END
    }
    params do
      requires :username, type: String, regexp:User::VALID_USERNAME_REGEX
      optional :name, type: String, regexp:/\A.{1,50}\z/, desc:"User's full name, 1 to 50 characters, including whitespace and special characters"
      requires :email, type: String, regexp: /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,6}$.?/i, desc:'e.g. oscar@madisononline.com'
      requires :password, type: String
      requires :udid, type: String, desc:"Unique identifier for the device"
      requires :device_type, type: String, desc:"Device model - e.g. 'iPhone 5s'"
      requires :os_version, type: String, desc:"OS Version - e.g. 'iOS 7.1'"
    end
    post 'register', http_codes:[
      [400, "1000 - Invalid params"],
      [404, "1001 - Record not found"],
      [500, "1002 - Server error"]
    ] do
      ActiveRecord::Base.transaction do
        user = User.create! declared_params.slice(:username, :name, :email, :password).merge(password_confirmation:declared_params[:password])
        device = Device.where(udid: declared_params[:udid]).first_or_create declared_params.slice(:device_type, :os_version)
        device.update_attributes! declared_params.slice(:device_type, :os_version)
        ownership = Ownership.find_by(device_id: device.id, user_id: user.id) || user.own!(device)

        ownership
      end
    end

    desc 'Log in a user', {
      notes: <<-END
        Returns an ownership record.
        Use the remember_token and the udid in other API calls to identify the authenticity of this user.
        The remember_token should be stored securely on the device - it is equivalent to a password.
        This call invalidates any previous remember_token.

        #### Example response
            {
              "id": 8,
              "remember_token": "58f1218d6b26fa563401efee2d5208061dee8de5",
              "user": {
                "id": 9,
                "username": "troy4",
                "name": "troy4"
              }
            }

      END
    }
    params do
      requires :username, type: String, regexp:User::VALID_USERNAME_REGEX
      requires :password, type: String
      requires :udid, type: String, desc:"Unique identifier for the device"
      requires :device_type, type: String, desc:"Device model - e.g. 'iPhone 5s'"
      requires :os_version, type: String, desc:"OS Version - e.g. 'iOS 7.1'"
    end
    post 'login' do
      user = User.find_by(username: declared_params[:username].downcase)
      fail! 403, "forbidden: invalid username and password combination, access denied" unless user && user.valid_password?(declared_params[:password])
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

      ownership
    end



    desc "Return a list of users for the given 'page'"
    params do
      requires :udid, type: String, desc:"Unique identifier for the device"
      requires :remember_token, type: String, desc:"Token obtained from register or login"
      requires :page, type: Integer
    end
    post 'list_index' do
      authorize_user!

      {success:User.paginate(page:declared_params[:page])}
    end



    desc "Become friends with all other users"
    params do
      requires :udid, type: String, desc:"Unique identifier for the device"
      requires :remember_token, type: String, desc:"Token obtained from register or login"
    end
    post 'autofriend_all_users' do
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
      requires :udid, type: String, desc:"Unique identifier for the device"
      requires :remember_token, type: String, desc:"Token obtained from register or login"
    end
    post 'friends' do
      { success: { friends: current_user.friends } }
    end


    desc "Return a list of users the caller is following"
    params do
      requires :udid, type: String, desc:"Unique identifier for the device"
      requires :remember_token, type: String, desc:"Token obtained from register or login"
      requires :page, type: Integer
    end
    post 'following' do
      users = current_user.followed_users.paginate page: declared_params[:page]
      { success:users }
    end


    desc "Return a list of users following this user"
    params do
      requires :udid, type: String, desc:"Unique identifier for the device"
      requires :remember_token, type: String, desc:"Token obtained from register or login"
      requires :page, type: Integer
    end
    post 'followers' do
      users = current_user.followers.paginate page: declared_params[:page]
      { success:users }
    end


    desc "Return a list of this user's devices"
    params do
      requires :udid, type: String, desc:"Unique identifier for the device"
      requires :remember_token, type: String, desc:"Token obtained from register or login"
      requires :page, type: Integer
    end
    post 'devices' do
      devices = current_user.devices.paginate page: declared_params[:page]
      { success:devices }
    end


    desc "Return a list of this user's microposts"
    params do
      requires :udid, type: String, desc:"Unique identifier for the device"
      requires :remember_token, type: String, desc:"Token obtained from register or login"
      requires :page, type: Integer
    end
    post 'microposts' do
      microposts = current_user.microposts.paginate page: declared_params[:page]
      { success:microposts }
    end


    desc "Follow the identified user"
    params do
      requires :udid, type: String, desc:"Unique identifier for the device"
      requires :remember_token, type: String, desc:"Token obtained from register or login"
      requires :username, desc: "User to follow"
    end
    post 'follow' do
      other_user = User.find_by username:declared_params[:username]

      fail! 2001, "Cannot follow yourself" if current_user == other_user
      current_user.follow! other_user

      {success: other_user}
    end


    desc "Stop following the identified user"
    params do
      requires :udid, type: String, desc:"Unique identifier for the device"
      requires :remember_token, type: String, desc:"Token obtained from register or login"
      requires :username, desc: "User to follow"
    end
    post ':id/unfollow' do
      other_user = User.find_by username:declared_params[:username]

      fail! 2002, "Cannot unfollow yourself" if current_user == other_user
      current_user.unfollow! other_user

      {success:other_user}
    end
  end
end
