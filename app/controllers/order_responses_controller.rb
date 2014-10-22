class OrderResponsesController < ResponsesController

  protected

    def response_params
      params.require(:order_response).permit(:user_id, :question_id, :text, :type, :anonymous, choice_responses_attributes:[:id, :order_choice_id, :position], comment_attributes:[ :id, :body, :user_id, :commentable_id ])
    end
end