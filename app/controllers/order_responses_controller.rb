class OrderResponsesController < ResponsesController

  protected

    def response_params
      params.require(:order_response).permit(:user_id, :question_id, :text, :type, :comment, :anonymous, choice_responses_attributes:[:id, :order_choice_id, :position])
    end
end