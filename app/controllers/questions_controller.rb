class QuestionsController < ApplicationController

  def index
    per_page = 6
    @questions = policy_scope(Question).paginate(page: params[:page], per_page:per_page)

    if user_signed_in? && @questions.count < per_page * params[:page].to_i + per_page + 1
      current_user.feed_more_questions per_page + 1
      @questions = policy_scope(Question).paginate(page: params[:page], per_page:per_page)
    end

  end

  def summary
    @question = Question.find params[:id]
    authorize @question

    @next_question = next_question @question

    # Generate summary info
    @all_comments = []
    @friend_comments = []
  end

  def new
    @question = current_user.questions.new
    @question_types=question_ty
    authorize @question
  end

end