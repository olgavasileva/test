class Responses::ChoiceResponsesController < ResponsesController
  def create
    @response = Response.new choice_response_params
    authorize @response
    if @response.save
      flash[:success] = "Thank you for your response!"
    else
      flash[:error] = "Unable to save your response."
    end

    redirect_to root_path
  end

  protected

    def choice_response_params
      params.require(:choice_response).permit(:user_id, :question_id, :choice_id, :type)
    end
end