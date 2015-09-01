class ListiclesController < ApplicationController

  before_action :load_and_authorize, only: [:show, :edit, :update, :destroy]

  rescue_from ActiveRecord::RecordNotFound do
    head 404
  end

  layout 'pixel_admin'

  def index
    @listicles = current_user.listicles
    policy_scope @listicles
  end

  def show
  end

  def new
    @listicle = Listicle.new
    @listicle.questions.build
    authorize @listicle
  end

  def edit
  end

  def create
    @listicle = current_user.listicles.new listicle_params
    authorize @listicle
    if @listicle.save
      redirect_to listicles_path, only_path: true
    else
      render :new
    end
  end

  def update
    @listicle.update(listicle_params)
    redirect_to_index
  end

  def destroy
    @listicle.destroy
    redirect_to_index
  end

  def image_upload
    authorize Listicle.new
    uploader = ListicleQuestionImageUploader.new
    uploader.store!(params[:file])
    render json: {
               image: {
                   url: uploader.to_s
               }
           }, content_type: 'text/html'
  end

  def answer_question
    question = ListicleQuestion.find(params[:question_id])
    authorize question.listicle
    answer = question.responses.find_by(user_id: current_ad_unit_user.id)
    answer.destroy if answer.present?
    question.responses.create!(response_params.merge(user_id: current_ad_unit_user.id))
    render json: {score: question.score}
  end

  def embed
    headers.delete 'X-Frame-Options'
    @listicle = Listicle.find(params[:id])
    authorize @listicle
    render :show, layout: 'listicle_embed'
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
    @cookie_user ||= if cookies.signed["listicle_user_#{Rails.env}"]
                       Respondent.find_by(id: cookies.signed["listicle_user_#{Rails.env}"])
                     end
  end

  def store_eu_user(user_id)
    cookies.permanent.signed["listicle_user_#{Rails.env}"] = {
        value: user_id,
        domain: nil # request.host.split('.').last(2).join('.')
    }
  end

  def load_and_authorize
    @listicle = current_user.listicles.find params[:id]
    authorize @listicle
  end

  def listicle_params
    params.require(:listicle).permit :title, :header, :footer, :questions_attributes => [:title, :body, :_destroy, :id]
  end

  def redirect_to_index
    redirect_to listicles_path, only_path: true
  end

  def response_params
    params.permit :is_up
  end
end