class YesNoQuestionsController < ApplicationController
  def new
    @question = YesNoQuestion.new user:current_user, image_index: rand(Question::CANNED_IMAGE_PATHS.count)
    @question.choices.build title:"Yes"
    @question.choices.build title:"No"
    authorize @question
  end

  def create
    @question = Question.new yes_no_question_params.merge(user_id:current_user.id)
    authorize @question

    if @question.save
      redirect_to :root
    else
      flash[:error] = "There was a problem creating your question." unless @question.save
      render "new"
    end
  end

  protected
    def yes_no_question_params
      params.require(:yes_no_question).permit(:type, :title, :category_id, :image_index, :rotate, choices:[:title])
    end
end