class TwoCents::Auth < Grape::API
  helpers do
    def validate_api_signature! token, signature
      fail! 1000, 'Invalid API signature' unless Digest::SHA2.hexdigest(token + Figaro.env.api_shared_secret).downcase == signature.downcase
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
      Figaro.env.google_gtm
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

        ```
        {
          "instance_token": "SOME_STRING",
          "api_domain": "https://somewhere.com",
          "google_gtm": "GTM-SOMETHING",
          "background_images": [
            "http://some.url.png",
            "http://some.other.url.png"
          ],
          "background_images_retina": [
            "http://some.url@2x.png",
            "http://some.other.url@2x.png"
          ]
          "faq_url": "http://some.url.com?page=123"
          "feedback_url": "http://some.url.com?page=124"
          "about_url": "http://some.url.com?page=125"
          "terms_and_conditions_url": "http://some.url.com?page=126",
          "ad_units": [
            {
              "name": "skyscraper",
              "width": 90,
              "height": 700,
              "default_meta_data": {"some": "data"}
            }
          ]
        }
        ```
      END
    }
    params do
      requires :api_signature, type: String, desc:'SAH2(device_vendor_identifier + shared_secret)'
      requires :device_vendor_identifier, type: String, desc:'Unique identifier for the device - should be the same whenever called from the same device'
      requires :platform, type: String, values: %w{ios web}, desc:'Possible values: ios, web'
      requires :manufacturer, type: String, desc:'e.g. Apple, Samsung, Atari, Dell, Acer'
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

      hash = Hash[Setting.enabled.map{|s| [s.key, s.value] }].merge({
        instance_token:instance.uuid,
        api_domain:api_domain,
        background_images:CannedQuestionImage.all.map{ |i| i.device_image_url },
        background_images_retina:CannedQuestionImage.all.map{ |i| i.retina_device_image_url },
        background_choice_images:CannedChoiceImage.all.map{ |i| i.device_image_url },
        background_choice_images_retina:CannedChoiceImage.all.map{ |i| i.retina_device_image_url },
        background_order_choice_images:CannedOrderChoiceImage.all.map{ |i| i.device_image_url },
        background_order_choice_images_retina:CannedOrderChoiceImage.all.map{ |i| i.retina_device_image_url }
      })

      hash[:ad_units] = AdUnit.all.map do |unit|
        unit.as_json(only: [:name, :width, :height, :default_meta_data])
      end

      # Remove sensitive AWS info except for the iOS app
      unless declared_params[:manufacturer] == "Apple Inc." && declared_params[:platform] == "ios"
        %w(aws_access_key aws_secret_access_key aws_region aws_bucket).each do |key|
          hash.delete key
        end
      end

      hash
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
      requires :token, type: String, regexp: /^<?([0-9A-F]{8} ?){8}>?$/i, desc:'e.g. "0000000000000000000000000000000000000000000000000000000000000000"'
      requires :environment, type: String, values:%w{production development}, desc:'Possible values: production|development'
    end
    post 'push_token', http_codes: [
        [200, "1001 - Invalid instance token"],
      ] do

      validate_instance!

      token = declared_params[:token].fixup_push_token

      existing_instance = Instance.find_by push_token:token

      if instance != existing_instance
        existing_instance.update_attributes! push_token:nil unless existing_instance.nil?
        instance.update_attributes! push_token:token, push_environment:declared_params[:environment]
      end

      {}
    end
  end

  resource :users do
    desc "Return an auth_token for the newly registered user who can login with an email/password", {
      notes: <<-END
        Add a new user with the given name.  Use the resulting auth_token in API
        calls that require a logged in user. In the future, this user can log in
        again by using the same email and password.

        ### Example response
        ```
        {
          auth_token: "SOME_STRING",
          user_id: 123
        }
        ```

        ### Associating a social provider account when registering

        If you have previously attempted to login a user using the
        `users/promote_social.json` endpoint, but the response indicated
        that the login was not successful and gave you a `provider_id`, you
        should supply that `provider_id` when registering the user so we may
        associate that user with their social provider account.
      END
    }
    params do
      requires :instance_token, type:String, desc:'Obtain this from the instances API'
      optional :email, type: String, desc:'e.g. oscar@madisononline.com'
      requires :username, type: String, regexp: /^[A-Z0-9\-_ ]{4,20}$/i, desc:'Unique username'
      requires :password, type: String, regexp: /.{6,20}/, desc:'6-20 character password'
      optional :name, type: String, desc:"The user's name"
      optional :birthdate, type: String, desc: '1990-02-06'
      optional :gender, type:String, values: %w{male female}, desc: 'male or female'
      optional :provider_id, type: Integer, desc: 'The social provider account to associate with this user'
    end
    post 'register', http_codes:[
        [200, "1001 - Invalid instance token"],
        [200, "1002 - A user with that email is already registered"],
        [200, "1009 - The Username is already taken"],
        [200, "1010 - Birthdate must be over 13 years ago"],
        [200, "1011 - Unable to save the user record (specific reason text will be included)"],
        [200, "1012 - Provider could not be found"],
        [200, "400 - Missing required params"]
      ] do

      validate_instance!

      fail! 1002, "This email address is already registered, try again." if declared_params[:email].present? && User.find_by(email:declared_params[:email])
      fail! 1009, "This username is already taken, try again." if User.find_by username:declared_params[:username]

      user = User.new name:declared_params[:name],
                      email:declared_params[:email],
                      username:declared_params[:username],
                      password:declared_params[:password],
                      password_confirmation:declared_params[:password],
                      birthdate:declared_params[:birthdate] ? Date.strptime(declared_params[:birthdate], '%Y-%m-%d') : nil,
                      gender:declared_params[:gender]

      user.update_tracked_fields(request)
      fail! 1010, "Birthdate must be over 13 years ago" if user.under_13?
      fail! 1011, user.errors.full_messages.join(", ") unless user.save

      if declared_params[:provider_id]
        auth = Authentication.find_by(id: declared_params[:provider_id])
        fail! 1012, "Provider could not be found" unless auth
        auth.update!(user: user)
      end

      instance.update_attributes! user:user, auth_token: "A"+UUID.new.generate
      LoginResponse.respond_with(instance)
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
      optional :birthdate, type: String, desc:"The user's birthdate - must be over 13"
    end
    post 'register/facebook', http_codes:[
        [200, "1001 - Invalid instance token"],
        [200, "1002 - Could not access facebook profile"],
        [200, "1003 - Facebook profile has no email"],
        [200, "1004 - Facebook profile has no name"],
        [200, "1009 - Username is already taken"],
        [200, "400 - Missing required params"]
      ] do

      validate_instance!

      fail! 1009, "Username is already taken" if User.find_by username:declared_params[:username]

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
        user = User.new name:fb_profile['name'], email:fb_profile['email'], username:declared_params[:username], birthdate:declared_params[:birthdate] unless user

        user.authentications.new provider:"facebook", uid:fb_profile['id'], token:declared_params[:facebook_token]
        user
      end

      user.update_tracked_fields(request)
      user.save!

      instance.update_attributes! auth_token: "A"+UUID.new.generate, user: user
      LoginResponse.respond_with(instance)
    end

    desc "Register as an anonymous user", {
      notes: <<-END
        Add a new anonymous user.  Use the resulting auth_token in API calls that require a logged in user.
        In the future, this user can be promoted to an autnenticatable user using the promote API.

        #### Example response
            { auth_token: "SOME_STRING", username:"BlackCat123", email:"BlackCat123@anonymous.statisfy.co", user_id: 123 }
      END
    }
    params do
      requires :instance_token, type:String, desc:'Obtain this from the instances API'
    end
    post 'anonymous', http_codes: [
        [200, "1001 - Invalid instance token"],
        [200, "1011 - Unable to save the user record (specific reason text will be included)"],
        [200, "400 - Missing required params"]
    ] do
      validate_instance!

      user = Anonymous.new
      user.update_tracked_fields(request)
      fail! 1011, user.errors.full_messages.join(", ") unless user.save

      instance.update_attributes! auth_token: "A"+UUID.new.generate, user: user
      LoginResponse.respond_with(instance)
    end

    desc "Promote an anonymous user to an authenticatable user", {
      notes: <<-END
        This API validates that the email/password match. If so, the instance
        gets a new auth_token and any previously obtained auth_token for this
        instance will become invalid.

        ### Example response
        ```
        {
          auth_token: "SOME_STRING",
          user_id: 123
        }
        ```

        ### Associating a social provider account when registering

        If you have previously attempted to login a user using the
        `users/promote_social.json` endpoint, but the response indicated
        that the login was not successful and gave you a `provider_id`, you
        should supply that `provider_id` when registering the user so we may
        associate that user with their social provider account.
      END
    }
    params do
      requires :auth_token, type: String, desc: "Obtain this by registering as an anonymous user"
      optional :email, type: String, desc:'e.g. oscar@madisononline.com'
      requires :username, type: String, regexp: /^[A-Z0-9\-_ ]{4,20}$/i, desc:'Unique username'
      requires :password, type: String, regexp: /.{6,20}/, desc:'6-20 character password'
      optional :name, type: String, desc:"The user's name"
      optional :birthdate, type: String, desc: '1990-02-06'
      optional :gender, type:String, values: %w{male female}, desc: 'male or female'
      optional :provider_id, type: Integer, desc: 'The social provider id to associate with this user'
    end
    post 'promote', http_codes: [
        [200, "1002 - A user with that email is already registered"],
        [200, "1009 - The Username is already taken"],
        [200, "1010 - Birthdate must be over 13 years ago"],
        [200, "1011 - Unable to save the user record (specific reason text will be included)"],
        [200, "1012 - User must be anonymous"],
        [200, "1013 - Provider could not be found"],
        [200, "400 - Missing required params"],
        [200, "402 - Invalid auth token"],
        [200, "403 - Login required"]
    ] do
      validate_user!

      user = current_user

      fail! 1012, "User must be anonymous" unless user.kind_of? Anonymous
      fail! 1002, "This email address is already registered, try again." if declared_params[:email].present? && User.find_by(email: declared_params[:email])
      fail! 1009, "This username is already taken, try again." if User.find_by username:declared_params[:username]

      ActiveRecord::Base.transaction do
        user.update_attribute :type, "User"
        user = User.find user.id
        user.name = declared_params[:name]
        user.email = declared_params[:email]
        user.username = declared_params[:username]
        user.password = declared_params[:password]
        user.password_confirmation = declared_params[:password]
        user.gender = declared_params[:gender]
        user.birthdate = if declared_params[:birthdate]
          Date.parse(declared_params[:birthdate]) rescue nil
        end

        user.update_tracked_fields(request)
        fail! 1010, "Birthdate must be over 13 years ago" if user.under_13?
        fail! 1011, user.errors.full_messages.join(", ") unless user.save

        if declared_params[:provider_id]
          auth = Authentication.find_by(id: declared_params[:provider_id])
          fail! 1013, "Provider could not be found" unless auth
          auth.update!(user: user)
        end

        @instance.update_attributes! auth_token: "A"+UUID.new.generate
      end

      LoginResponse.respond_with(@instance)
    end

    desc "Associates the OAuth provider with the current user", {
      notes: <<-END
        NOTE - Anonymous users are automatically promoted to regular users
        NOTE - the auth_token returned from this API should be used in future API requests.

        ### Example Responses

        #### When User was logged in
        ```
          {
            success: true,
            provider_valid: true,
            auth_token: "some_auth_token",
            email: "example#me.com", // might be empty
            username: "some_username",
            user_id: 1
          }
        ```

        When you receive this response, you should proceed as though you have an
        authenticated user.

        #### When User could not be logged in but the provider was valid
        ```
          {
            success: false,
            provider_valid: true,
            provider_id: 1
          }
        ```

        When you receive this response, you should assume that we were able to
        access the provider and store the authentication recored associated with
        it, but there was no user to login. Therefore, the user should be
        redirected to a signup or login page, where you will send the
        `provider_id` you received from this payload as part of the `promote` or
        `login` enpoint payload.
      END
    }
    params do
      requires :instance_token, type: String, desc: 'Obtain this from the instances API'
      requires :provider, type: String, desc: "A valid provider. Can be one of: #{Authentication::PROVIDERS.join(',')}"
      requires :provider_token, type: String, desc: 'The token obtained through the authentication handshake'
      optional :provider_secret, type: String, desc: 'The secret token obtained through the authentication handshake'
    end
    post 'promote_social', http_codes: [
      [200, "1001 - Instance token invalid"],
      [200, "1002 - Provider invalid"],
      [200, "1003 - Could not access profile"],
      [200, "1004 - No user record can be determined"],
      [200, "1011 - Unable to save the user record (specific reason text will be included)"],
      [200, "400 - Missing required params"],
      [200, "402 - Invalid auth token"],
      [200, "403 - Login required"]
    ] do
      validate_instance!

      unless Authentication::PROVIDERS.include?(declared_params[:provider])
        fail! 1002, "Provider invalid: #{declared_params[:provider]}"
      end

      profile = SocialProfile.build(
        declared_params[:provider],
        declared_params[:provider_token],
        declared_params[:provider_secret]
      )

      fail! 1003, "Could not access profile" unless profile.valid?

      auth = Authentication.from_social_profile(profile)

      Authentication.transaction do
        if instance.user.is_a?(Anonymous)
          if auth.user.present?
            instance.user = auth.user
          else
            password = SecureRandom.hex(16)
            auth.user = instance.user.promote!({
              name: profile.name,
              password: password,
              password_confirmation: password
            })
          end
        elsif instance.user.present?
          auth.user = instance.user
        elsif auth.user.present?
          instance.user = auth.user
        else
          auth.save!
        end

        if auth.user.present?
          auth.user.update_tracked_fields!(request)
          auth.save!
          instance.refresh_auth_token
          instance.save!
        end
      end

      LoginResponse.respond_with(instance, auth)
    end

    desc 'Remove a users social login', notes: 'Returns 204 No Content on success'
    params do
      requires :auth_token
      requires :provider_id, type: Integer, desc: 'The users social provider id to remove'
    end
    delete 'social' do
      validate_user!
      auth = current_user.authentications.find(declared_params[:provider_id])
      auth.destroy!
      status 204
    end

    desc "Return an auth_token for the newly logged in user", {
      notes: <<-END
        This API validates that the email/password match. If so, the instance
        gets a new auth_token and any previously obtained auth_token for this
        instance will become invalid.

        **One of email or username is requried.**

        ### Example response
        ```
        {
          auth_token: "SOME_STRING",
          user_id: 123
        }
        ```

        ### Associating a social provider account at login

        If you have previously attempted to login a user using the
        `users/promote_social.json` endpoint, but the response indicated
        that the login was not successful and gave you a `provider_id`, you
        should supply that `provider_id` when logging in the user so we may
        associate that user with their social provider account.
      END
    }
    params do
      requires :instance_token, type:String, desc:'Obtain this from the instances API'
      requires :password, type: String, regexp: /.{6,20}/, desc:'6-20 character password'
      optional :email, type: String, desc:'e.g. oscar@madisononline.com'
      optional :username, type: String, regexp: /^[A-Z0-9\-_ ]{4,20}$/i, desc:'Unique username'
      optional :provider_id, type: Integer, desc: 'The social provider id to associate with this user'
      mutually_exclusive :email, :username
    end
    post 'login', http_codes: [
        [200, "1001 - Invalid instance token"],
        [200, "1004 - Email not found"],
        [200, "1005 - Username not found, try again"],
        [200, "1006 - Neither email nor username supplied"],
        [200, "1007 - Only one of email ane username are allowed"],
        [200, "1008 - Wrong password"],
        [200, "1012 - Provider could not be found"],
        [200, "400 - Missing required params"],
        [200, "400 - [:email, :username] are mutually exclusive"]
      ] do

      validate_instance!

      fail! 1006, "Neither email nor username supplied" unless declared_params[:email] || declared_params[:username]

      user = if declared_params[:email]
        User.find_by email:declared_params[:email]
      else
        User.find_by username:declared_params[:username]
      end

      unless user.present? && user.valid_password?(declared_params[:password])
        fail! 1008, "Login Unsuccessful. The username and password you entered did not match our records. Please double-check and try again."
      end

      if declared_params[:provider_id]
        auth = Authentication.find_by(id: declared_params[:provider_id])
        fail! 1012, "Provider could not be found" unless auth
        auth.update!(user: user)
      end

      user.update_tracked_fields!(request)
      instance.update_attributes! auth_token: "A"+UUID.new.generate, user: user

      LoginResponse.respond_with(instance)
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
      instance.update_attributes! auth_token: nil, user: nil

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
      optional :email, type: String, desc:'e.g. oscar@madisononline.com'
      optional :username, type: String, regexp: /^[A-Z0-9\-_ ]{4,20}$/i, desc:'Unique username'
      mutually_exclusive :email, :username
    end
    post 'reset_password', http_codes: [
        [200, "1001 - Invalid instance token"],
        [200, "1011 - User not found"],
        [200, "1013 - User does not have an email address"]
      ] do

      validate_instance!

      user = User.find_by email:declared_params[:email] if declared_params[:email].present?
      user = User.find_by username:declared_params[:username] if declared_params[:username].present?

      fail! 1011, "User not found" unless user
      fail! 1013, "User does not have an email address" unless user.email.present?

      user.send_reset_password_instructions

      {}
    end

    desc "Update logged in user's location"
    params do
      requires :instance_token, type: String, desc: "Obtain this from the instance's API"
      requires :auth_token, type: String, desc: "Obtain this by registering"

      requires :source, type: String, values: %w[IP gps], desc: "Location source"
      requires :accuracy, type: Integer, desc: "Location accuracy"
      optional :longitude, type: String, desc: "Location longitude"
      optional :latitude, type: String, desc: "Location longitude"
    end
    post 'location' do
      validate_instance!

      if params[:source] == 'IP'
        ip = env['REMOTE_ADDR']
        longitude, latitude = Geocoder.search(ip).first.coordinates
      else
        longitude, latitude = params[:longitude], params[:latitude]

        if longitude.nil? || latitude.nil?
          fail! 400, "gps source requires longitude and latitude"
        end
      end

      current_user.update_attributes longitude: longitude, latitude: latitude

      {}
    end

    desc "Return initial info on current user."
    params do
      requires :auth_token, type: String, desc: "Obtain this by registering"
    end
    get 'init' do
      validate_user!

      {
        has_any_groups: current_user.groups.any?,
        manages_any_communities: current_user.communities.any?
      }
    end

    desc 'Returns user settings'
    params do
      requires :auth_token, type: String, desc: 'Obtain this by registering'
    end
    get 'settings', jbuilder: 'user_settings' do
      validate_user!
    end

    desc 'Updates user settings and returns the updated information'
    params do
      requires :auth_token, type: String, desc: 'Obtain this by registering'
      optional :push_on_question_answered, type: Integer, desc: 'Notification frequency for quesitons answered'
      optional :push_on_question_asked, type: Integer, desc: 'Notification frequency for quesitons asked'
    end
    put 'settings', jbuilder: 'user_settings' do
      validate_user!
      settings = declared_params.except(:auth_token)
      current_user.update!(settings)
    end
  end

  resource 's3_urls' do
    desc "Return array of presigned s3 upload objects."
    params do
      requires :auth_token, type: String, desc: "Obtain this by registering"
      requires :upload_count, type: Integer, values: [1, 2, 3, 4], desc: "Number of signed urls to return as integer, max is 4."
      optional :content_type, type: String, default: "image/jpg", desc: "Content type for the uploaded image(s)"
    end

    post 'generate' do
      validate_user!

      presigned_obj = []
      obj_fields = []

      declared_params[:upload_count].times do
        presigned_obj << S3_BUCKET.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", success_action_status: 201, acl: :public_read, content_type: declared_params[:content_type])
      end

      presigned_obj.each do |obj|
        obj_fields << {url: obj.url}.merge(obj.fields)
      end
      obj_fields
    end
  end
end
