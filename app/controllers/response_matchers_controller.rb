class ResponseMatchersController < ApplicationController
  before_action :find_segment, only: [:new, :create]

  def new
    @question = Question.find params[:question_id]
    @response_matcher = @question.response_matchers.new segment:@segment, inclusion:'respond'
    authorize @response_matcher
    render layout: false
  end

  def create
    @question = Question.find matcher_params[:question_id]
    @response_matcher = ResponseMatcher.new matcher_params
    authorize @response_matcher

    @response_matcher.save
  end

  def destroy
    @response_matcher = ResponseMatcher.find params[:id]
    authorize @response_matcher

    @response_matcher.destroy
  end

  protected
    def find_segment
      @segment = Segment.find params[:segment_id]
    end

end