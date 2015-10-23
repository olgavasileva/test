class ListicleQuestionsController < ApplicationController
  respond_to :html, :json

  before_action :find_and_authorize_question

  def update
    @listicle_question.update listicle_params
    render json: {question: {id: @listicle_question.id, title: @listicle_question.title}}, status: :ok
  end

  def edit
    render 'listicles/questions/edit', layout: false
  end

  private

  def find_and_authorize_question
    @listicle_question = ListicleQuestion.find params[:question_id]
    authorize @listicle_question
  end

  def listicle_params
    params.require(:question).permit(:body, :script)
  end
end
