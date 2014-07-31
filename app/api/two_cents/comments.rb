class TwoCents::Comments < Grape::API
  resource :comments do

    desc "Get all comments for a question", {
      notes: <<-END
        #### Example response
            [
              {
                "id": 97,
                "comment": "Hi There"
              },
              {
                "id": 105,
                "comment": "What does this mean?"
              }
            ]
      END
    }
    params do
      requires :auth_token, type:String, desc: 'Obtain this from the instances API'
      requires :question_id, type:Integer, desc: 'The id of the question'
    end
    post '/', rabl:"comments", http_codes:[
      [200, "400 - Invalid params"],
      [200, "402 - Invalid auth token"],
      [200, "403 - Login required"]
    ] do
      question = Question.find declared_params[:question_id]
      @responses = question.responses_with_comments
    end


    desc "Like a comment", {
      notes: <<-END
      END
    }
    params do
      requires :auth_token, type:String, desc: 'Obtain this from the instances API'
      requires :comment_id, type:Integer, desc: 'The id of the comment to like'
    end
    post 'like', rabl:"comments", http_codes:[
      [200, "400 - Invalid params"],
      [200, "402 - Invalid auth token"],
      [200, "403 - Login required"]
    ] do
      response = Response.find declared_params[:comment_id]
      response.comment_likers << current_user
      response.save!

      { num_likes: response.comment_likers.count }
    end

  end
end