class Responses::ChoiceResponsesController < ResponsesController

  protected

    def response_params
      params.require(:choice_response).permit(:user_id, :question_id, :choice_id, :type)
    end
end