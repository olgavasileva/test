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
    if question.responses.find_by(user_id: current_ad_unit_user.id)
      render json: {error: 'You have already answered this question'}, status: :bad_request
    else
      question.responses.create!(response_params.merge(user_id: current_ad_unit_user.id))
      render json: {score: question.score}
    end
  end

  def embed
    headers.delete 'X-Frame-Options'
    @listical = Listical.find(params[:id])
    authorize @listical
    render :show, layout: 'listical_embed'
  end

  private

  def current_ad_unit_user
    @ad_unit_user ||= begin
      ad_unit_user = cookie_user || Anonymous.create!(auto_feed: false)
      store_eu_user(ad_unit_user.id)
      ad_unit_user
    end
  end

  def cookie_user
    @cookie_user ||= if cookies.signed["eu_user_#{Rails.env}"]
                       Respondent.find_by(id: cookies.signed["eu_user_#{Rails.env}"])
                     end
  end

  def store_eu_user(user_id)
    cookies.permanent.signed["eu_user_#{Rails.env}"] = {
        value: user_id,
        domain: request.host.split('.').last(2).join('.')
    }
  end

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