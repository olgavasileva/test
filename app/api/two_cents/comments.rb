class TwoCents::Comments < Grape::API
  resource :comments do

    desc "Return questions with comments for a user"
    params do
      requires :auth_token, type: String, desc: "Obtain this from the instance's API."

      optional :user_id, type: Integer, desc: "User ID. Defaults to logged in user's ID."
      optional :page, type: Integer, desc: "Page number, minimum 1. If left blank, responds with all questions."
      optional :per_page, type: Integer, default: 15, desc: "Number of questions per page."
    end
    post 'user' do
      user_id = params[:user_id]
      user = user_id.present? ? User.find(user_id) : current_user

      responses = user.responses.with_comment

      if params[:page]
        responses = responses.paginate(page: params[:page],
                                       per_page: params[:per_page])
      end

      responses.map do |r|
        {
          question_id: r.question.id,
          question_title: r.question.title
        }
      end
    end

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
