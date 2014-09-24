class ResponseMatchersController < ApplicationController
  def new
    question = Question.find params[:question_id]
    @response_matcher = question.response_matchers.new
    authorize @response_matcher
    render layout: false
  end

  def create
    question = Question.find matcher_params[:question_id]
    @response_matcher = ResponseMatcher.new matcher_params
    authorize @response_matcher

    @response_matcher.save
  end

end