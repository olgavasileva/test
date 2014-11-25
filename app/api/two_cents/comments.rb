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
          comment_count: c.user.comments.count,
          comment_children: c.comments.map { |c| serialize_comment(c) }
        }
      end
    end

    desc "Return questions with comments for a user"
    params do
      requires :auth_token, type: String, desc: "Obtain this from the instance's API."

      optional :user_id, type: Integer, desc: "User ID. Defaults to logged in user's ID."
      optional :reverse, type: Boolean, default: false, desc: "Whether to reverse order."
      optional :previous_last_id, type: Integer,
        desc: "ID of question before start of list."
      optional :count, type: Integer,
        desc: "Number of questions to return."
    end
    post 'user' do
      user_id = declared_params[:user_id]
      previous_last_id = params[:previous_last_id]
      count = params[:count]

      user = user_id.present? ? User.find(user_id) : current_user

      comments = user.comments.order(:created_at)
      comments = comments.reverse if params[:reverse]
      questions = comments.map(&:question).uniq.compact

      if previous_last_id.present?
        previous_last_index = questions.map(&:id).index(previous_last_id)
        questions = questions[previous_last_index + 1..-1]
      end

      if count.present?
        questions = questions.first(count)
      end

      questions.map do |q|
        last_commented_at =  q.comments.where(id: comments)
                              .order('created_at DESC').first
                              .try(:created_at).try(:to_i) || 0
        last_commented_at2 = q.response_comments.where(id: comments)
                              .order('created_at DESC').first
                              .try(:created_at).try(:to_i) || 0

        {
          question_id: q.id,
          question_title: q.title,
          last_commented_at: [last_commented_at, last_commented_at2].max
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
    get nil, http_codes: [
      [200, "400 - Invalid params"],
      [200, "402 - Invalid auth token"],
      [200, "403 - Login required"]
    ] do
      question = Question.find declared_params[:question_id]
      comments = question.comments + question.response_comments

      comments.map { |c| serialize_comment(c) }
    end

    desc "Create a comment."
    params do
      requires :auth_token, type: String, desc: "Obtain this from the instance's API."

      requires :question_id, type: Integer, desc: "Comment question ID."
      optional :content, type: String, desc: "Comment body content."
      optional :parent_id, type: Integer, desc: "Parent comment ID."
    end
    post do
      validate_user!

      if params[:content].present?
        commentable = if declared_params[:parent_id].present?
          Comment.find declared_params[:parent_id]
        else
          Question.find(params[:question_id])
        end

        comment = commentable.comments.create user:current_user, body:declared_params[:content]

        serialize_comment(comment)
      else
        # act as `GET /comments` for backward-compatibility
        question = Question.find declared_params[:question_id]
        comments = question.comments + question.response_comments

        comments.map { |c| serialize_comment(c) }
      end
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
