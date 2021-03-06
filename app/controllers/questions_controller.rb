class QuestionsController < ApplicationController

  before_action :find_and_authorize, except: [:index, :new, :new_response_from_uuid]

  def index
    if ENV['REDIRECT_QUESTIONS_NEW_TO_WEBAPP'].true? && @embeddable_unit.nil?
      policy_scope(Question) # satisfy authorization check
      redirect_to ENV['WEB_APP_URL']
    else
      per_page = 8
      @questions = policy_scope(Question).latest.kpage(params[:page]).per(per_page)
      @questions.each { |q| q.viewed! }
    end
  end

  def summary
    @commentable = @question

    @next_question = next_question @question
  end

  def new
    @question = current_user.questions.new
    authorize @question
  end

  def preview

    @response = @question.responses.new(user: current_user)
    @response.build_comment(user: current_user)
  end

  def new_response_from_uuid
    @question = Question.find_by uuid: params[:uuid]
    @question ||= Question.find_by id: params[:uuid] # 11/4/14 temporary fix for device using ID in stead of UUID in links


    if @question.present?
      authorize @question

      if browser.bot?
        redirect_to new_question_response_path(@question)
      else
        url = File.join(ENV['WEB_APP_URL'], "#/app/question", @question.id.to_s)
        query = {referral: request.referrer}.to_query
        redirect_to "#{url}?#{query}"
      end
    else
      authorize Question, :index?
      redirect_to :root
    end
  end

  def update_targetable

    @question.update_attribute :currently_targetable, update_targetable_params[:currently_targetable] != 'false'

    render text: "OK"
  end

  def skip
    @question.skipped! current_user

    next_q = next_question @question
    if next_q
      redirect_to new_question_response_path(next_q)
    else
      redirect_to :root
    end
  end

  def results
  end

  def edit
    render layout: false
  end

  def update
    @question.update question_attributes
    render json: {title: @question.title}, status: :accepted
  end

  private

  def update_targetable_params
    params.require(:question).permit(:currently_targetable)
  end

  def question_attributes
    params.require(:question).permit(:title, :choices_attributes => [:id, :title, :targeting_script])
  end

  def find_and_authorize
    @question = Question.find params[:id]
    authorize @question
  end
end
