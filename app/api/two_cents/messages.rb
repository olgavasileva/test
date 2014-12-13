class TwoCents::Messages < Grape::API
  resource :messages do

    #
    # Returns the number of unread messages
    #
    desc "Return number of unread messages", {
        notes: <<-END
        This API will update the status of a message which belongs to the current user.

        #### Example response

          {number_of_unread_messages : 4}
        END
    }
    params do
      requires :auth_token, type:String, desc: 'Obtain this from the instances API'
    end
    get 'number_of_unread_messages', http_codes:[
        [200, "400 - Invalid params"],
        [200, "402 - Invalid auth token"],
        [200, "403 - Login required"]
    ] do
      validate_user!


      @number = current_user.number_of_unread_messages
      { number_of_unread_messages: @number }
    end

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

    desc "Mark multiple messages as read"
    params do
      requires :auth_token, type: String, desc: "Obtain this from the instance's API."
      requires :ids, type: Array, desc: "IDs of messages."
    end
    put 'read_multiple' do
      validate_user!

      params[:ids].map do |id|
        message = Message.find(id)
        message.touch(:read_at)
      end

      {}
    end



    #
    # Set all messages in the queue read
    #
    desc "Set all messages in the queue read", {
        notes: <<-END
        This API will Set all messages in the queue ,which belongs to the current user, read.

                        inputs:
                          auth_token: token of current user

                        output:
                          success: empty body {} and success response code
        END
    }
    params do
      requires :auth_token, type:String, desc: 'Obtain this from the instances API'
    end
    post 'read_all', http_codes:[
        [200, "400 - Invalid params"],
        [200, "402 - Invalid auth token"],
        [200, "403 - Login required"]
    ] do
      validate_user!

      current_user.read_all_messages

      status 200
      {}

    end


    #
    # Delete all messages
    #
    desc "Delete all messages in the queue", {
        notes: <<-END
        This API will Delete all messages in the queue ,which belongs to the current user.

                                inputs:
                                  auth_token: token of current user

                                output:
                                  success: empty body {} and success response code
        END
    }
    params do
      requires :auth_token, type:String, desc: 'Obtain this from the instances API'
    end
    post 'delete_all', http_codes:[
        [200, "400 - Invalid params"],
        [200, "402 - Invalid auth token"],
        [200, "403 - Login required"]
    ] do
      validate_user!

      current_user.messages.all().each do |message|
        message.destroy!
      end

      status 200
      {}

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

    desc "Return an array of messages for this user.", {
      notes: <<-END
        This API will return an ordered list of messages for this user.

        #### Example response
            {
                "messages":
                    [
                        {
                            "message":
                              {
                                  "id": 1,
                                  "type": "QuestionUpdated",
                                  "body": "QuestionUpdated",
                                  "question_id": 123
                                  "response_count": 3,
                                  "comment_count": 2,
                                  "share_count": 2,
                                  "completed_at": 1231231234,        # timestamp
                                  "created_at": 1231231234           # timestamp
                                  "read_at": nil              # timestamp
                              }
                        },
                        {
                            "message":
                              {
                                  "id": 2,
                                  "type": "UserFollowed",
                                  "body": "UserFollowed",
                                  "follower_id": 123,
                                  "created_at": 1231231234           # timestamp
                                  "read_at": nil              # timestamp
                              }
                        },
                        {
                            "message":
                              {
                                  "id": 3,
                                  "type": “Custom”,
                                  "body": "Custom",
                                  "created_at": 1231231234           # timestamp
                                  "read_at": 1231231234              # timestamp
                              }
                        }
                    ],
                "number_of_unread_messages": 2
            }
      END
    }
    params do
      requires :auth_token, type:String, desc: 'Obtain this from the instances API'
      optional :page, type: Integer, desc: "Page number, starting at 1 - all messages returned if not supplied"
      optional :per_page, type: Integer, default: 15, desc: "Number of messages per page"
    end
    post '/', jbuilder: "messages", http_codes:[
      [200, "400 - Invalid params"],
      [200, "402 - Invalid auth token"],
      [200, "403 - Login required"]
    ] do
      validate_user!

      page = declared_params[:page]
      per_page = page ? declared_params[:per_page] : nil
      messages = policy_scope(Message).newest_first

      @messages = messages.paginate(page:page, per_page:per_page)
      @number = current_user.number_of_unread_messages
    end

    desc "Return messages for this user.", {
      notes: <<-END
        This API will return an ordered list of messages for this user.

        #### Example response
            {
                "messages":
                    [
                        {
                            "message":
                              {
                                  "id": 1,
                                  "type": "QuestionUpdated",
                                  "body": "QuestionUpdated",
                                  "question_id": 123
                                  "response_count": 3,
                                  "comment_count": 2,
                                  "share_count": 2,
                                  "completed_at": 1231231234,        # timestamp
                                  "created_at": 1231231234           # timestamp
                                  "read_at": nil              # timestamp
                              }
                        },
                        {
                            "message":
                              {
                                  "id": 2,
                                  "type": "UserFollowed",
                                  "body": "UserFollowed",
                                  "follower_id": 123,
                                  "created_at": 1231231234           # timestamp
                                  "read_at": nil              # timestamp
                              }
                        },
                        {
                            "message":
                              {
                                  "id": 3,
                                  "type": “Custom”,
                                  "body": "Custom",
                                  "created_at": 1231231234           # timestamp
                                  "read_at": 1231231234              # timestamp
                              }
                        }
                    ],
                "number_of_unread_messages": 2
            }
      END
    }
    params do
      requires :auth_token, type: String, desc: "Obtain this from the instance's API."
      optional :previous_last_id, type: Integer, desc: "ID of message to return messages after."
      optional :count, type: Integer, desc: "Number of messages to return."
    end
    get '/', jbuilder: 'messages' do
      validate_user!

      previous_last_id = params[:previous_last_id]
      count = params[:count]

      @messages = policy_scope(Message).newest_first

      if previous_last_id.present?
        previous_last_index = @messages.map(&:id).index(previous_last_id)
        @messages = @messages[previous_last_index + 1..-1]
      end

      if count.present?
        @messages = @messages.first(count)
      end

      @number = current_user.number_of_unread_messages
    end
  end

end
