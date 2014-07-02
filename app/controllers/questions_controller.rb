class QuestionsController < ApplicationController
  load_and_authorize_resource

  layout "clean_canvas"

  def index
    @categories = Category.where(id:@questions.group(:category_id).map{|question| question.category_id}).order(:name)
    @questions = @questions.order("created_at DESC")
  end

  def show
    render layout:false
  end

  def update
  end

end