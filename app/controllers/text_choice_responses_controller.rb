class TextChoiceResponsesController < ResponsesController

  protected

    def response_params
      params.require(:text_choice_response).permit(:user_id, :question_id, :choice_id, :type, comment_attributes:[ :id, :body, :user_id, :commentable_id ])
    end
end
