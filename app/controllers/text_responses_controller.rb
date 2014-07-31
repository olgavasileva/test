class TextResponsesController < ResponsesController

  protected

    def response_params
      params.require(:text_response).permit(:user_id, :question_id, :text, :type, :choice_id , :comment,:anonymous)

    end
end