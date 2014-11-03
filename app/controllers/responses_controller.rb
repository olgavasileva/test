class ResponsesController < ApplicationController
  def new
    @question = Question.find params[:question_id]
    @question.started!

    @response = @question.responses.new user: current_user
    @response.build_comment user:current_user
    authorize @response

    @next_question = next_question @question
    @just_answered = params[:just_answered]
  end

  def create
    @response = Response.new response_params

    authorize @response

    if @response.save
      # Special case for TextQuestion: create comment matching response.
      if @response.question.is_a?(TextQuestion) && @response.comment.nil?
        Comment.create(body: @response.text, user: @response.user,
                       commentable_type: "Question",
                       commentable_id: @response.question_id)
      end

      current_user.feed_items.where(question:@response.question).destroy_all

      if session[:demo]
        redirect_to question_path
      elsif session[:contest_uuid]
        contest = Contest.find_by uuid:session[:contest_uuid]
        next_question = contest.next_question(@response.question)
        if next_question
          redirect_to new_question_response_path(next_question)
        else
          redirect_to contest_vote_path(contest.uuid)
        end
      else
        redirect_to summary_question_path(@response.question)
      end
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
