class QuestionsController < ApplicationController

  def index
    per_page = 6
    @questions = policy_scope(Question).paginate(page: params[:page], per_page:per_page)

    if session[:demo]
      redirect_to question_path
    else
      if user_signed_in? && @questions.count < per_page * params[:page].to_i + per_page + 1
        current_user.feed_more_questions per_page + 1
        @questions = policy_scope(Question).paginate(page: params[:page], per_page:per_page)
      end

      @questions.each{|q| q.viewed!}
    end
  end

  def summary
    @question = Question.find params[:id]
    authorize @question

    @next_question = next_question @question

    # Generate summary info
    @responses_resume={}
    @question.responses.all.each do |c|
      @responses_resume[c.choice_id]||=0
      @responses_resume[c.choice_id]+=1
    end
    @all_comments = []
    @friend_comments = []
  end

  def new
    @question = current_user.questions.new
    authorize @question
  end

end