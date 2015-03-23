class TwoCents::Profile < Grape::API
  resource :profile do
    desc "Return the profile of current user", {
      notes: <<-NOTES
        This API will return the profile of current user.

        #### Example Response: Public
        ```
        {
          "profile": {
              "username": "Endre",
              "user_id": "1",
              "email": "endre1234@gmail.com",
              "member_since": "2014-08-26T10:04:03+00:00",
              "number_of_answered_questions": "1",
              "number_of_asked_questions": "2",
              "number_of_comments_left": "1",
              "number_of_followers": "1"
          }
        }
        ```

        #### Example Response: Pro User

        This will be the same as the public response, but include the following:

        ```
        {
          "profile": {
            // Public profile data plus:
            "pro_dashboard_url": http://api.statisfy.co/users/:id/dashboard?auth_token=:auth_token
          }
        }
        ```

        #### Example Response: Current User

        These attributes will only be returned when the user being requested is
        also the user making the request.

        ```
        {
          "profile": {
            // Public profile data plus:
            "providers": [
              {
                "id": 1,
                "provider": "facebook"
              },
              {
                "id": 2,
                "provider": "twitter"
              }

            ]
          }
        }
        ```
      NOTES
    }
    params do
      requires :auth_token, type:String, desc:'Obtain this from the instances API'
      optional :user_id, type: Integer, desc: "ID of user, defaults to current user's ID"
    end
    post "/", jbuilder: "profile", http_codes:[
        [200, "402 - Invalid auth token"],
        [200, "403 - Login required"]
    ] do
      validate_user!
      @user = if declared_params[:user_id]
        Respondent.find(declared_params[:user_id])
      else
        current_user
      end
    end

    desc "Upload user's avatar"
    params do
      requires :auth_token, type:String, desc:'Obtain this from the instances API'
      requires :image_url, type: String, desc: "URL to avatar image."
    end
    post 'headshot' do
      validate_user!

      image_url = declared_params[:image_url]

      if URI(image_url).scheme.nil?
        UserAvatar.create! user:current_user, image: open(image_url)
      else
        UserAvatar.create! user:current_user, remote_image_url: image_url
      end

      {}
    end

    desc "Get user's avatar", {
      notes: <<-END
        This API will return the avatar for the current user or given user, if supplied.
        Will return the url to the gravatar based on their email if they have not supplied a custom headshot.

              #### Example response
              {
                  "avatar_url": "http://gravatar.com/avatar/2dfca61aac39cb1700dd73295a9ff160.jpg?d=identicon"
              }
        END
    }
    params do
      requires :auth_token, type: String, desc:'Obtain this from the instances API'
      optional :user_id, type: Integer, desc: "User ID. Defaults to logged in user's ID."
    end
    get 'headshot', jbuilder:'headshot' do
      validate_user!

      @user = declared_params[:user_id] ? Respondent.find(declared_params[:user_id]) : current_user
    end

  end
end
