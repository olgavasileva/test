class YesNoQuestionsController < ApplicationController
  def new
    @question = YesNoQuestion.new user: current_user
    @question.choices.build title:"Yes"
    @question.choices.build title:"No"
    authorize @question
  end

  def create
    @question = YesNoQuestion.new yes_no_question_params.merge(user_id:current_user.id, state:params[:commit] == "Preview" ? "preview" : "active")
    authorize @question

    if @question.save
      redirect_to @question.preview? ? new_question_response_path(@question) : :root
    else
      flash[:error] = "There was a problem creating your question."
      render "new"
    end
  end

  def edit
    @question = YesNoQuestion.find params[:id]
    authorize @question
  end

  def update
    @question = YesNoQuestion.find params[:id]
    authorize @question

    if @question.update yes_no_question_params.merge(state:params[:commit] == "Preview" ? "preview" : "active")
      redirect_to @question.preview? ? new_question_response_path(@question) : :root
    else
      flash[:error] = "There was a problem updating your question."
      render :edit
    end
  end

  def enable
    @question = YesNoQuestion.find params[:id]
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
    def yes_no_question_params
      params.require(:yes_no_question).permit(:type, :title, :category_id, :background_image_id, :rotate, choices_attributes:[:id, :title])
    end
end