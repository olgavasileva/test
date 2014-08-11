class TextChoiceQuestionsController < ApplicationController
  def new
    @question = TextChoiceQuestion.new user:current_user
    authorize @question
    @question.choices.build title:"Option one"
    @question.choices.build title:"Option two"
  end

  def create
    @question = TextChoiceQuestion.new text_choice_question_params.merge(user_id:current_user.id)
    authorize @question

    if @question.save
      redirect_to :root
    else
      flash[:error] = "There was a problem creating your question."
      render "new"
    end
  end

  protected
    def text_choice_question_params
      params.require(:text_choice_question).permit(:type, :title, :category_id, :background_image_id, :rotate, choices_attributes:[:id, :title, :_destroy])
    end
end
