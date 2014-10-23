class QuestionsController < ApplicationController
  def index
    per_page = 6
    @questions = policy_scope(Question).kpage(params[:page]).per(per_page)

    if session[:demo]
      redirect_to question_path
    else
      if user_signed_in? && @questions.count < per_page * params[:page].to_i + per_page + 1
        current_user.feed_more_questions per_page + 1
        @questions = policy_scope(Question).kpage(params[:page]).per(per_page)
      end

      @questions.each{|q| q.viewed!}
    end
  end

  def summary
    @question = Question.find params[:id]
    authorize @question

    @next_question = next_question @question
  end

  def new
    @question = current_user.questions.new
    authorize @question
  end

  def new_response_from_uuid
    @question = Question.find_by uuid:params[:uuid]
    authorize @question

    redirect_to new_question_response_path(@question) unless browser.iphone? || browser.ipod? || browser.ipad?
  end

  def update_targetable
    @question = Question.find params[:id]
    authorize @question

    @question.update_attribute :currently_targetable, update_targetable_params[:currently_targetable] != 'false'

    render text:"OK"
  end

  def results
    @question = Question.find params[:id]
    authorize @question
  end

  private
    def update_targetable_params
      params.require(:question).permit(:currently_targetable)
    end

end
