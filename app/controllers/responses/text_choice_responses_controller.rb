class Responses::TextChoiceResponsesController < ResponsesController

  protected

    def response_params
      params.require(:text_choice_response).permit(:user_id, :question_id, :choice_id, :type)
    end
end