class TextResponsesController < ResponsesController

  protected

    def response_params
      params.require(:text_response).permit(:user_id, :question_id, :text, :type, :choice_id, :anonymous, comment_attributes:[ :id, :body, :user_id, :commentable_id ])

    end
end
