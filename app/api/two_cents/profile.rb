class TwoCents::Profile < Grape::API
  resource :profile do
    desc "Return the profile of current user", {
        notes: <<-END
        This API will return the profile of current user.

              #### Example response
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

        END
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

      @user = User.find(params.fetch(:user_id, current_user.id))
    end
  end
end
