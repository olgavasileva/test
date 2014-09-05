class TwoCents::Messages < Grape::API
  resource :messages do
    #
    # Return the messages of current user
    #

    desc "Return an array of questions and related data for this user.", {
      notes: <<-END
        This API will return an ordered list of unanswered questions for this user.

        #### Example response
            [
                {
                    "Message": {
                        "type": "CommentLikedMessage",
                        "content": "What a nice Comment! I loved it.",
                        "read_at": "2014-09-05 23:53:38 UTC",
                        "created_at": "2014-09-04 23:53:38 UTC",
                    }
                },
                {
                    "Message": {
                        "type": "DirectQuestionMessage",
                        "content": "I failed to grab the real meaning of this question. Can you please tell me what it was?",
                        "read_at": "2014-09-05 23:53:38 UTC",
                        "created_at": "2014-09-04 23:53:38 UTC",
                    }
                },
                {
                    "Message": {
                        "type": "QuestionLikedMessage",
                        "content": "What a nice Question! I loved it.",
                        "read_at": "2014-09-05 23:53:38 UTC",
                        "created_at": "2014-09-04 23:53:38 UTC",
                    }
                },

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
