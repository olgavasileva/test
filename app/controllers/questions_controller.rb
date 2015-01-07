class QuestionsController < ApplicationController
  def index
    per_page = 8
    @questions = policy_scope(Question).latest.kpage(params[:page]).per(per_page)
    @questions.each{|q| q.viewed!}
  end

  def summary
    @question = Question.find params[:id]
    @commentable = @question
    authorize @question

    @next_question = next_question @question
  end

  def new
    @question = current_user.questions.new
    authorize @question
  end

  def preview
    @question = Question.find(params[:id])
    authorize @question

    @response = @question.responses.new(user: current_user)
    @response.build_comment(user: current_user)
  end

  def new_response_from_uuid
    @question = Question.find_by uuid:params[:uuid]
    @question ||= Question.find_by id:params[:uuid]   # 11/4/14 temporary fix for device using ID in stead of UUID in links


    if @question.present?
      authorize @question

      if ENV['LEGACY_SOCIAL_LINKS'].true?
        redirect_to new_question_response_path(@question) unless %w(true 1).include?(ENV['DEVICE_SHARING_REDIRECT'].to_s.downcase) && (browser.iphone? || browser.ipod? || browser.ipad?)
      else
        # Forward to new app unless it's a bot
        redirect_to File.join(ENV['WEB_APP_URL'], "#/app/question/710") unless browser.bot?
      end
    else
      authorize Question, :index?
      redirect_to :root
    end
  end

  def update_targetable
    @question = Question.find params[:id]
    authorize @question

    @question.update_attribute :currently_targetable, update_targetable_params[:currently_targetable] != 'false'

    render text:"OK"
  end

  def skip
    @question = Question.find params[:id]
    authorize @question
    FeedItem.question_skipped! @question, current_user

    next_q = next_question @question
    if next_q
      redirect_to new_question_response_path(next_q)
    else
      redirect_to :root
    end
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
