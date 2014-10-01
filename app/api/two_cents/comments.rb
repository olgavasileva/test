class TwoCents::Comments < Grape::API
  resource :comments do
    helpers do
      def serialize_comment(c)
        {
          id: c.id,
          user_id: c.user_id,
          comment: c.body,
          created_at: c.created_at.to_i,
          email: c.user.email,
          ask_count: c.user.questions.count,
          response_count: c.user.responses.count,
          comment_count: c.user.responses.with_comment.count,
          comment_children: c.children.map { |c| serialize_comment(c) }
        }
      end
    end

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
    get http_codes: [
      [200, "400 - Invalid params"],
      [200, "402 - Invalid auth token"],
      [200, "403 - Login required"]
    ] do
      questions = Question.find declared_params[:question_id]
      comments = questions.comments.root

      comments.map { |c| serialize_comment(c) }
    end

    desc "Create a comment."
    params do
      requires :auth_token, type: String, desc: "Obtain this from the instance's API."
      requires :question_id, type: Integer, desc: "Question for comment."
      requires :body, type: String, desc: "Comment body."
    end
    post do
      validate_user!

      question = Question.find(params[:question_id])
      comment = Comment.create!(question_id: params[:question_id],
                                user_id: current_user.id,
                                body: params[:body])

      serialize_comment(comment)
    end


    desc "Like a comment", {
      notes: <<-END
      END
    }
    params do
      requires :auth_token, type:String, desc: 'Obtain this from the instances API'
      requires :comment_id, type:Integer, desc: 'The id of the comment to like'
    end
    post 'like', http_codes:[
      [200, "400 - Invalid params"],
      [200, "402 - Invalid auth token"],
      [200, "403 - Login required"]
    ] do
      comment = Comment.find declared_params[:comment_id]
      comment.likers << current_user
      comment.save!

      { num_likes: comment.likers.count }
    end

  end
end
