class QuestionsController < ApplicationController
  layout "clean_canvas"

  def index
    @questions = policy_scope Question
    @categories = Category.where(id:@questions.group(:category_id).map{|question| question.category_id}).order(:name)
  end

  def show
    @question = Question.find params[:id]
    authorize @question

    @response = @question.responses.new user:current_user
    @next_question = next_question @question
    @just_answered = params[:just_answered]
  end

  def summary
    @question = Question.find params[:id]
    authorize @question

    @next_question = next_question @question

    # Generate summary info
    @all_comments = []
    @friend_comments = []
  end

  private

    def next_question question
      question_ids = policy_scope(Question).pluck(:id)
      index = question_ids.find_index @question.id
      Question.find question_ids[index + 1] if index < question_ids.count - 1
    end
end