class TextQuestionsController < ApplicationController
  def new
    @question = TextQuestion.new user:current_user
    authorize @question
  end

  def create
    @question = TextQuestion.new text_question_params.merge(user_id:current_user.id)
    authorize @question

    if @question.save
      redirect_to :root
    else
      flash[:error] = "There was a problem creating your question."
      render "new"
    end
  end

  protected
    def text_question_params
      params.require(:text_question).permit(:type, :title, :category_id, :background_image_id)
    end
end
