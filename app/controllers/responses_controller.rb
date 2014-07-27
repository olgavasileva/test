class ResponsesController < ApplicationController
  def create
    @response = Response.new response_params
    authorize @response

    # On a successful response, show the results for this question, otherwise handle it in the responses/create.js.coffee
    redirect_to summary_question_path(@response.question) if @response.save
  end


  protected

    def response_params
      raise NotImplementedError.new("You must implement response_params.")
    end
end