class ListicalsController < ApplicationController

  before_action :load_and_authorize, only: [:show, :edit, :update, :destroy]

  rescue_from ActiveRecord::RecordNotFound do
    head 404
  end

  layout 'pixel_admin'

  def index
    @listicals = current_user.listicals
    policy_scope @listicals
  end

  def show
  end

  def new
    @listical = Listical.new
    @listical.questions.build
    authorize @listical
  end

  def edit
  end

  def create
    @listical = current_user.listicals.new listical_params
    authorize @listical
    if @listical.save
      redirect_to listicals_path, only_path: true
    else
      render :new
    end
  end

  def update
    redirect_to_index
  end

  def destroy
    @listical.destroy
    redirect_to_index
  end

  def image_upload
    authorize Listical.new
    uploader = ListicalQuestionImageUploader.new
    uploader.store!(params[:file])
    render json: {
               image: {
                   url: uploader.to_s
               }
           }, content_type: 'text/html'
  end

  def answer_question
    question = ListicalQuestion.find(params[:question_id])
    authorize question.listical
    question.responses.create(response_params.merge(:user_id => current_user.id))
    redirect_to listical_path(question.listical), only_path: true
  end

  private

  def load_and_authorize
    @listical = current_user.listicals.find params[:id]
    authorize @listical
  end

  def listical_params
    params.require(:listical).permit :title, :header, :footer, :questions_attributes => [:title, :body, :_destroy]
  end

  def redirect_to_index
    redirect_to listicals_path, only_path: true
  end

  def response_params
    params.permit :is_up
  end
end