class ResponsesController < ApplicationController
  def create
    @response = Response.new response_params
    authorize @response
    if @response.save
      # On a successful response, go to the next question, otherwise handle it in the responses/create.js.coffee
      redirect_to question_path(params[:next_question_id], just_answered:true) if params[:next_question_id]
    end
  end


  protected

    def response_params
      raise NotImplementedError.new("You must implement response_params.")
    end
end