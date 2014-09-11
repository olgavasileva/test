class TwoCents::Messages < Grape::API
  resource :messages do

    #
    # Update the read status of a message
    #
    desc "Update the status of a message", {
        notes: <<-END
                This API will update the status of a message which belongs to the current user.

                inputs:
                  id: id of the message to be marked as read

                output:
                  error if message doesn't exist
                  error if message doesn't belong to current_user
                  error if message has already been read
                  success: empty body("[]") and success response code
        END
    }
    params do
      requires :auth_token, type:String, desc: 'Obtain this from the instances API'
      requires :id, type: Integer, desc: 'ID of the target message'
    end
    post 'read', http_codes:[
        [200, "400 - Invalid params"],
        [200, "402 - Invalid auth token"],
        [200, "403 - Login required"],
        [200, "2000 - The message doesn't exist"],
        [200, "2001 - The message doesn't belong to current_user"],
        [200, "2002 - The message has already been read"],
        [200, "2003 - Failed to update the read status of the message"]
    ] do
      validate_user!



      fail!(2000, "The message doesn't exist") if !Message.exists?(declared_params[:id])

      message = Message.find(declared_params[:id])
      fail!(2001, "The message doesn't belong to current_user") if message.user != current_user
      fail!(2002, "The message has already been read") if message.read_at

      message.read_at = Time.zone.now()

      if message.save
        status 200
        body []
      else
        fail!(2003, "Failed to update the read status of the message")
      end
    end

    #
    # Delete a message
    #
    desc "Delete a message", {
        notes: <<-END
        This API will delete a message which belongs to the current user.

                        inputs:
                          id: id of the message to be deleted

                        output:
                          error if message doesn't exist
                          error if message doesn't belong to current_user
                          success: empty body("[]") and success response code
        END
    }
    params do
      requires :auth_token, type:String, desc: 'Obtain this from the instances API'
      requires :id, type: Integer, desc: 'ID of the target message'
    end
    post 'delete', http_codes:[
        [200, "400 - Invalid params"],
        [200, "402 - Invalid auth token"],
        [200, "403 - Login required"],
        [200, "2000 - The message doesn't exist"],
        [200, "2001 - The message doesn't belong to current_user"],
        [200, "2002 - Failed to delete the message"]
    ] do
      validate_user!



      fail!(2000, "The message doesn't exist") if !Message.exists?(declared_params[:id])

      message = Message.find(declared_params[:id])
      fail!(2001, "The message doesn't belong to current_user") if message.user != current_user

      message.read_at = Time.zone.now()

      if message.destroy
        status 200
        body []
      else
        fail!(2002, "Failed to delete the message")
      end
    end


    #
    # Return the messages sent to current user
    #

    desc "Return an array of questions and related data for this user.", {
      notes: <<-END
        This API will return an ordered list of unanswered questions for this user.

        #### Example response
            [
                {
                    "type": "QuestionUpdated",
                    "question_id": 123
                    "response_count": 3,
                    "comment_count": 2,
                    "share_count": 2,
                    "completed_at": 1231231234,        # timestamp
                    "created_at": 1231231234           # timestamp
                    "read_at": 1231231234              # timestamp
                },
                {
                    "type": "UserFollowed",
                    "follower_id": 123,
                    "created_at": 1231231234           # timestamp
                    "read_at": 1231231234              # timestamp
                }
            ]
      END
    }
    params do
      requires :auth_token, type:String, desc: 'Obtain this from the instances API'
      optional :page, type: Integer, desc: "Page number, starting at 1 - all questions returned if not supplied"
      optional :per_page, type: Integer, default: 15, desc: "Number of questions per page"
    end
    post '/', rabl: "messages", http_codes:[
      [200, "400 - Invalid params"],
      [200, "402 - Invalid auth token"],
      [200, "403 - Login required"]
    ] do
      validate_user!

      page = declared_params[:page]
      per_page = page ? declared_params[:per_page] : nil
      messages = policy_scope(Message)

      @messages = messages.paginate(page:page, per_page:per_page)
    end


  end
end
