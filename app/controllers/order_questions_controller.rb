class OrderQuestionsController < ApplicationController
  def new
    @question = OrderQuestion.new user:current_user
    authorize @question
    @question.choices.build title:"Answer 1"
    @question.choices.build title:"Answer 2"
  end

  def create
    @question = OrderQuestion.new order_question_params.merge(user_id:current_user.id, state:params[:commit] == "Preview" ? "preview" : "active")
    authorize @question

    if @question.save
      redirect_to @question.preview? ? new_question_response_path(@question) : :root
    else
      flash[:error] = "There was a problem creating your question."
      render "new"
    end
  end

  def edit
    @question = OrderQuestion.find params[:id]
    authorize @question
  end

  def update
    @question = OrderQuestion.find params[:id]
    authorize @question

    if @question.update order_question_params.merge(state:params[:commit] == "Preview" ? "preview" : "active")
      redirect_to @question.preview? ? new_question_response_path(@question) : :root
    else
      flash[:error] = "There was a problem updating your question."
      render :edit
    end
  end

  def enable
    @question = OrderQuestion.find params[:id]
    authorize @question

    if @question.update_attributes state:"active"
      flash[:error] = "The question is now active."
      redirect_to :root
    else
      flash[:error] = "There was a problem enabling your question."
      render :edit
    end
  end

  protected
    def order_question_params
      params.require(:order_question).permit(:type, :title, :category_id, choices_attributes:[:id, :title, :background_image_id])
    end
end
