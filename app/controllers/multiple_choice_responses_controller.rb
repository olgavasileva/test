class MultipleChoiceResponsesController < ResponsesController

  protected

    def response_params
      params.require(:multiple_choice_response).permit(:user_id, :question_id, :type, choice_ids:[], comment_attributes:[ :id, :body, :user_id, :commentable_id ])
    end
end
