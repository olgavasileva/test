class ResponsesController < ApplicationController

  def new
    question = Question.find params[:question_id]
    @response = question.responses.new user:current_user
    authorize @response

    @next_question = next_question question
    @just_answered = params[:just_answered]
  end

  def create
    @response = Response.new response_params
    authorize @response

    if @response.save
      redirect_to summary_question_path(@response.question)
    else
      flash[:alert] = @response.errors.full_messages.join ", "
      @next_question = next_question @response.question
      render "new"
    end
  end

  protected

    def response_params
      raise NotImplementedError.new("You must implement response_params.")
    end
end