class ImageChoiceQuestionsController < ApplicationController
  def new
    @question = ImageChoiceQuestion.new user:current_user
    authorize @question
    @question.choices.build title:"Option one"
    @question.choices.build title:"Option two"
  end

  def create
    @question = ImageChoiceQuestion.new image_choice_question_params.merge(user_id:current_user.id, state:params[:commit] == "Preview" ? "preview" : "active")
    authorize @question

    if @question.save
      redirect_to @question.preview? ? new_question_response_path(@question) : :root
    else
      flash[:error] = "There was a problem creating your question."
      render "new"
    end
  end

  def edit
    @question = ImageChoiceQuestion.find params[:id]
    authorize @question
  end

  def update
    @question = ImageChoiceQuestion.find params[:id]
    authorize @question

    if @question.update image_choice_question_params.merge(state:params[:commit] == "Preview" ? "preview" : "active")
      redirect_to @question.preview? ? new_question_response_path(@question) : :root
    else
      flash[:error] = "There was a problem updating your question."
      render :edit
    end
  end

  def enable
    @question = ImageChoiceQuestion.find params[:id]
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
    def image_choice_question_params
      params.require(:image_choice_question).permit(:type, :title, :category_id, :rotate, choices_attributes:[:id, :title, :background_image_id, :_destroy])
    end
end