class ResponsesController < ApplicationController
  layout :resolve_layout

  after_action :allow_iframe, only: [:new, :create]

  def new
    @embeddable_unit = EmbeddableUnit.find_by uuid: cookies[:euuid]

    if !browser.bot? && ENV['REDIRECT_QUESTIONS_NEW_TO_WEBAPP'].true? && @embeddable_unit.nil?
      authorize Response.new  # satisfy authorization check
      redirect_to File.join(ENV['WEB_APP_URL'], "#/app/question", params[:question_id])
    else
      @question = Question.find params[:question_id]
      @question.started!

      @response = @question.responses.new user: current_user
      @response.build_comment user:current_user
      authorize @response

      @next_question = next_question @question
      @just_answered = params[:just_answered]
      @show_skip_button = !session[:contest_uuid]
      @show_root_button = !session[:contest_uuid]

      render 'embeddable_units/new_response' if @embeddable_unit
    end
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

      if cookies[:euuid]
        redirect_for_embedded_response cookies[:euuid], @response
      elsif session[:contest_uuid]
        redirect_for_contest_response session[:contest_uuid], @response
      else
        redirect_for_standard_response @response
      end

    else
      flash[:alert] = @response.errors.full_messages.join ", "
      @response.build_comment user:current_user unless @response.comment.present?
      @question = @response.question
      @next_question = next_question @response.question
      @show_skip_button = !session[:contest_uuid]
      @show_root_button = !session[:contest_uuid]
      @embeddable_unit = EmbeddableUnit.find_by uuid: cookies[:euuid]
      render @embeddable_unit ? 'embeddable_units/new_response' : "new"
    end
  end

  protected

    def resolve_layout
      if cookies[:euuid]
        "embeddable_unit"
      else
        "clean_canvas"
      end
    end

    def response_params
      raise NotImplementedError.new("You must implement response_params.")
    end

  private

    def redirect_for_standard_response response
      redirect_to summary_question_path(response.question)
    end

    def redirect_for_contest_response contest_uuid, response
      contest = Contest.find_by uuid: contest_uuid
      next_question = contest.survey.next_question(response.question)

      if next_question
        redirect_to new_question_response_path(next_question)
      else
        redirect_to contest_vote_path(contest_uuid)
      end
    end

    def redirect_for_embedded_response euuid, response
      eu = EmbeddableUnit.find_by uuid: euuid
      redirect_to embeddable_unit_summary_path(euuid, response)
    end

end
