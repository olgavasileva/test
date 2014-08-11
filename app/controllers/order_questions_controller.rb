class OrderQuestionsController < ApplicationController
  def new
    @question = OrderQuestion.new user:current_user
    authorize @question
    @question.choices.build title:"Answer 1"
    @question.choices.build title:"Answer 2"
  end

  def create
    @question = OrderQuestion.new order_question_params.merge(user_id:current_user.id)
    authorize @question

    if @question.save
      redirect_to :root
    else
      flash[:error] = "There was a problem creating your question."
      render "new"
    end
  end

  protected
    def order_question_params
      params.require(:order_question).permit(:type, :title, :category_id, choices_attributes:[:id, :title, :background_image_id])
    end
end
