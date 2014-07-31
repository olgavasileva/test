class ImageChoiceResponsesController < ResponsesController

  protected

    def response_params
      params.require(:image_choice_response).permit(:user_id, :question_id, :choice_id, :type)
    end
end