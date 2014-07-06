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

    # Skip the layout if this is an AJAX request
    render layout:false if request.xhr?
  end
end