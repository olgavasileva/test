class QuestionsController < ApplicationController

  def index
    @questions = policy_scope Question
    @categories = Category.where(id:@questions.group(:category_id).map{|question| question.category_id}).order(:name)
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
    authorize @question
  end

end