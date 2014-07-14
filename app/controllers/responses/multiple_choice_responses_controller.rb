class Responses::MultipleChoiceResponsesController < ResponsesController
  def create
    @response = MultipleChoiceResponse.new multiple_choice_response_params
    authorize @response
    if @response.save
      flash[:success] = "Thank you for your response!"
    else
      flash[:error] = "Unable to save your response."
    end

    redirect_to root_path
  end

  protected

    def multiple_choice_response_params
      params.require(:multiple_choice_response).permit(:user_id, :question_id, :type, choice_ids:[])
    end
end