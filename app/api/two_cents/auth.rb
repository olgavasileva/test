class TwoCents::Auth < Grape::API
  helpers do
    def validate_api_signature! token, signature
      fail! 1000, 'Invalid API signature' unless Digest::SHA2.hexdigest(token + Figaro.env["api_shared_secret"].to_s).downcase == signature.downcase
    end

    def instance
      @instance ||= Instance.find_by uuid:declared_params[:instance_token]
    end

    def validate_instance!
      fail! 1001, "Invalid instance token" unless instance
    end

    def api_domain
      # For now, just return the current host - e.g. https://www.example.com
      "#{URI(request.url).scheme}://#{URI(request.url).host}"
    end

    def google_gtm
      Figaro.env['google_gtm']
    end
  end

  resource :instances do
    desc "Return an instance_token - call at least at each launch, and possibly any time the app is brought to the foreground.", {
      notes: <<-END
        Call this API on each launch.  On the first launch, do not supply an instanance_token.
        On all subsequent launches, supply the instance token returned last time the method was called.
        If you receive an api_domain that is different than the one you're using, make this same call on it to get a valid instance token going forward.

        ### On the labs/staging environment, you can use the following for testing:
            # Note: the resulting instance_token will only be valid until someone else uses this same data
            api_signature: eee0326c65497495144b5382085ea4370b7003bddd9608b2d2f7616d0a3d7fc4
            device_vendor_identifier: TEST

        #### Example response
            {
              instance_token: "SOME_STRING",
              api_domain:"https://somewhere.com",
              google_gtm:"GTM-SOMETHING",
              background_images: [
                "http://some.url.png",
                "http://some.other.url.png"
              ]
            }
      END
    }
    params do
      requires :api_signature, type: String, desc:'SAH2(device_vendor_identifier + shared_secret)'
      requires :device_vendor_identifier, type: String, desc:'Unique identifier for the device - should be the same whenever called from the same device'
      requires :platform, type: String, values: %w{ios}, desc:'Possible values: ios'
      requires :manufacturer, type: String, desc:'e.g. Apple, Samsung, Atari'
      requires :model, type: String, desc:'e.g. iPhone 5s'
      requires :os_version, type: String, desc:'e.g. iOS 7.1'
      requires :app_version, type: String, desc:'e.g. 1.0.5'
      optional :instance_token, type: String, desc:'Supply the token returned from from this API on all subsequent calls'
    end
    post '/', http_codes:[
        [200, "1000 - Invalid API signature"],
        [200, "1001 - Invalid instance token"],
        [200, "1010 - Incompatible app version"],
        [200, "400 - Missing required params"]
      ] do

      # Fail if someone is trying to use "TEST" in the production environment
      fail! 1000, "Invalid API signature" if Rails.env.production? && declared_params[:device_vendor_identifier] == "TEST"

      validate_api_signature! declared_params[:device_vendor_identifier], declared_params[:api_signature]
      if declared_params[:instance_token]
        validate_instance!
        instance.device.update_attributes! platform:declared_params[:platform], manufacturer:declared_params[:manufacturer], model:declared_params[:model], os_version:declared_params[:os_version]
      else
        device = Device.find_or_create_by! device_vendor_identifier:declared_params[:device_vendor_identifier], platform:declared_params[:platform], manufacturer:declared_params[:manufacturer], model:declared_params[:model], os_version:declared_params[:os_version]
        @instance = device.instances.create!
      end

      fail! 1001, "Invalid instance token" if instance.nil?
      fail! 1010, "Incompatible app version" unless app_version_compatible? declared_params[:app_version]

      instance.update_attributes! launch_count:instance.launch_count.to_i + 1, app_version:declared_params[:app_version]

      { instance_token:instance.uuid, api_domain:api_domain, google_gtm:google_gtm, background_images:BackgroundImage.all.map{ |i| i.image_url } }
    end


    desc "Set or update the push token for the instance", {
      notes: <<-END
        Call this API whenever you get a push token from the OS.
        The response is an empty JSON hash.

        #### Example response
            {}
      END
    }
    params do
      requires :instance_token, type:String, desc:'Obtain this from the instances API'
      requires :token, type: String, regexp: /^[0-9A-F]{64}$/i, desc:'e.g. "0000000000000000000000000000000000000000000000000000000000000000"'
      requires :environment, type: String, values:%w{production development}, desc:'Possible values: production|development'
    end
    post 'push_token', http_codes: [
        [200, "1001 - Invalid instance token"],
      ] do

      validate_instance!

      existing_instance = Instance.find_by push_token:declared_params[:token]

      if instance != existing_instance
        existing_instance.update_attributes! push_token:nil unless existing_instance.nil?
        instance.update_attributes! push_token:declared_params[:token], push_environment:declared_params[:environment]
      end

      {}
    end
  end

  resource :users do
    desc "Return an auth_token for the newly registered user who can login with an email/password", {
      notes: <<-END
        Add a new user with the given name.  Use the resulting auth_token in API calls that require a logged in user.
        In the future, this user can log in again by using the same email and password.

        #### Example response
            { auth_token: "SOME_STRING" }
      END
    }
    params do
      requires :instance_token, type:String, desc:'Obtain this from the instances API'
      requires :email, type: String, regexp: /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,6}$.?/i, desc:'e.g. oscar@madisononline.com'
      requires :username, type: String, regexp: /^[A-Z0-9\-_ ]{4,20}$/i, desc:'Unique username'
      requires :password, type: String, regexp: /.{6,20}/, desc:'6-20 character password'
      requires :name, type: String, desc:"The user's name"
    end
    post 'register', http_codes:[
        [200, "1001 - Invalid instance token"],
        [200, "1002 - A user with that email is already registered"],
        [200, "1009 - Handle is already taken"],
        [200, "400 - Missing required params"]
      ] do

      validate_instance!

      fail! 1002, "A user with that email is already registered" if User.find_by email:declared_params[:email]
      fail! 1009, "Handle is already taken" if User.find_by username:declared_params[:username]

      user = User.create! name:declared_params[:name], email:declared_params[:email], username:declared_params[:username], password:declared_params[:password], password_confirmation:declared_params[:password]
      instance.update_attributes! user:user, auth_token:"A"+UUID.new.generate

      {auth_token:instance.auth_token}
    end


    desc "Return an auth_token for the exising or newly registered user who can login with facebook credentials", {
      notes: <<-END
        Add a new user with the given name.  Use the resulting auth_token in API calls that require a logged in user.
        In the future, this user can log in again by using the same facebook acccount.

        #### Example response
            { auth_token: "SOME_STRING" }
      END
    }
    params do
      requires :instance_token, type:String, desc:'Obtain this from the instances API'
      requires :username, type: String, regexp: /^[A-Z0-9\-_ ]{4,20}$/i, desc:'Unique username'
      requires :facebook_token, type: String, desc:"Token obtained from facebook's auth API"
    end
    post 'register/facebook', http_codes:[
        [200, "1001 - Invalid instance token"],
        [200, "1002 - Could not access facebook profile"],
        [200, "1003 - Facebook profile has no email"],
        [200, "1004 - Facebook profile has no name"],
        [200, "1009 - Handle is already taken"],
        [200, "400 - Missing required params"]
      ] do

      validate_instance!

      fail! 1009, "Handle is already taken" if User.find_by username:declared_params[:username]

      begin
        graph = Koala::Facebook::API.new declared_params[:facebook_token]
        fb_profile = graph.get_object "me"
      rescue Exception => e
        fail! 1002, "Could not access facebook profile: #{e.message}"
      end

      fail! 1003, "Facebook profile has no email" if fb_profile['email'].blank?
      fail! 1004, "Facebook profile has no name" if fb_profile['name'].blank?

      authentication = Authentication.find_by provider:'facebook', uid:fb_profile['id']

      user = if authentication
        authentication.user
      else
        user = User.find_by email:fb_profile['email']
        user = User.new name:fb_profile['name'], email:fb_profile['email'], username:declared_params[:username] unless user

        user.authentications.new provider:"facebook", uid:fb_profile['id'], token:declared_params[:facebook_token]
        user.save!
        user
      end

      instance.update_attributes! user_id:user.id, auth_token:"A"+UUID.new.generate
      {auth_token:instance.auth_token}
    end


    desc "Return an auth_token for the newly logged in user", {
      notes: <<-END
        This API validates that the email/password match.  If so, the instance gets a new auth_token and any previously obtained auth_token for this instance will become invalid.

        One of email or username is requried.

        #### Example response
            { auth_token: "SOME_STRING", email: "your@address.com", username: "Your Handle" }
      END
    }
    params do
      requires :instance_token, type:String, desc:'Obtain this from the instances API'
      requires :password, type: String, regexp: /.{8}.*/, desc:'8 or more character password'
      optional :email, type: String, regexp: /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,6}$.?/i, desc:'e.g. oscar@madisononline.com'
      optional :username, type: String, regexp: /^[A-Z0-9\-_ ]{4,20}$/i, desc:'Unique username'
      mutually_exclusive :email, :username
    end
    post 'login', http_codes: [
        [200, "1001 - Invalid instance token"],
        [200, "1004 - Email not found"],
        [200, "1005 - Handle not found"],
        [200, "1006 - Neither email nor username supplied"],
        [200, "1007 - Only one of email ane username are allowed"],
        [200, "1008 - Wrong password"],
        [200, "400 - Missing required params"],
        [200, "400 - [:email, :username] are mutually exclusive"]
      ] do

      validate_instance!

      fail! 1006, "Neither email nor username supplied" unless declared_params[:email] || declared_params[:username]

      if declared_params[:email]
        user = User.find_by email:declared_params[:email]
        fail! 1004, "Email not found" unless user
      else
        user = User.find_by username:declared_params[:username]
        fail! 1005, "Handle not found" unless user
      end

      fail! 1008, "Wrong password" unless user.valid_password? declared_params[:password]

      instance.update_attributes auth_token:"A"+UUID.new.generate, user:user

      {auth_token:instance.auth_token, email:user.email, username:user.username}
    end


    desc "Log out the user", {
      notes: <<-END
        Invalidate the auth_token for this instance.  To use the APIs, this instance will need to register or login to obtain a new auth_token.

        #### Example response
            {}
      END
    }
    params do
      requires :instance_token, type:String, desc:'Obtain this from the instances API'
    end
    post 'logout', http_codes: [
        [200, "1001 - Invalid instance token"],
      ] do

      validate_instance!
      instance.update_attributes! auth_token:nil, user:nil

      {}
    end

    desc "Reset password", {
      notes: <<-END
        Send the user an email to reset their password.

        #### Example response
            {}
      END
    }
    params do
      requires :instance_token, type:String, desc:'Obtain this from the instances API'
      optional :email, type: String, regexp: /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,6}$.?/i, desc:'e.g. oscar@madisononline.com'
      optional :username, type: String, regexp: /^[A-Z0-9\-_ ]{4,20}$/i, desc:'Unique username'
      mutually_exclusive :email, :username
    end
    post 'reset_password', http_codes: [
        [200, "1001 - Invalid instance token"],
        [200, "1011 - User not found"]
      ] do

      validate_instance!

      user = User.find_by email:declared_params[:email] if declared_params[:email].present?
      user = User.find_by username:declared_params[:username] if declared_params[:username].present?

      fail! 1011, "User not found" unless user

      user.send_reset_password_instructions

      {}
    end

  end
end