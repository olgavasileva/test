class ListiclesController < ApplicationController

  before_action :load_and_authorize, only: [:show, :edit, :update, :destroy]
  skip_before_action :verify_authenticity_token, only: [:image_upload] # TODO fix this

  rescue_from ActiveRecord::RecordNotFound do
    head 404
  end

  layout 'pixel_admin'

  def index
    @listicles = current_user.listicles.order :created_at => :desc
    policy_scope @listicles
  end

  def show
  end

  def new
    @listicle = current_user.listicles.new
    @listicle.questions.build
    authorize @listicle
  end

  def edit
  end

  def create
    @listicle = Listicle.new listicle_params.merge(user_id: current_user.id)
    authorize @listicle
    respond_to do |format|
      format.html do
        if @listicle.save
          redirect_to listicles_path, only_path: true
        else
          render :new
        end
      end
      format.json do
        if @listicle.save
          render json: {form: render_to_string(partial: 'listicles/advanced_form', layout: false, formats: :html)}, status: :created
        else
          render json: {errors: @listicle.errors.full_messages}, status: :bad_request
        end
      end
    end
  end

  def basic_form
    @listicle = current_user.listicles.find(params[:listicle_id])

    authorize @listicle
    render partial: 'basic_form'
  end

  def update
    @listicle.update(listicle_params)
    respond_to do |format|
      format.html { redirect_to action: :index }
      format.json { render json: {form: render_to_string(partial: 'listicles/advanced_form', layout: false, formats: :html)}, status: :ok }
    end
  end

  def destroy
    @listicle.destroy

    respond_to do |f|
      f.html { redirect_to_index }
      f.json { render nothing: true, status: :ok }
    end
  end

  def image_upload
    authorize Listicle.new
    uploader = ListicleQuestionImageUploader.new
    uploader.store!(params[:file])
    render json: {
               filelink: uploader.to_s
           }, content_type: 'text/html'
  end

  def search
    skip_authorization
    query = params[:term]
    listicles = current_user.listicles #.where('intro LIKE ?', "%#{query}%")
    render json: listicles.map { |listicle| {load_url: listicle_analytics_url(current_user, listicle), id: listicle.id, title: listicle.get_intro} }
  end

  def answer_question
    question = ListicleQuestion.find(params[:question_id])
    authorize question.listicle

    question.answer(response_params, current_ad_unit_user, request)

    render json: {score: question.score}
  end

  def embed
    @preview = params[:preview]
    headers.delete 'X-Frame-Options'
    @listicle = Listicle.find(params[:id])
    authorize @listicle
    @listicle.update(view_count: @listicle.view_count + 1)
    render :show, layout: 'listicle_embed'
  end

  def quantcast
    authorize(Listicle.new)
    DataProvider.where(name: 'quantcast').first_or_create
    demo = current_ad_unit_user.demographics.quantcast.first_or_create
    demo.ip_address = request.remote_ip
    demo.user_agent = request.env['HTTP_USER_AGENT']
    demo.update_from_provider_data!('quantcast', '1.0', params[:quantcast])
    head :ok
  end

  def details
    @listicle = current_user.listicles.where(id: params[:listicle_id]).includes(:questions => [:responses]).first
    options = {
        question_ids: @listicle.question_ids,
        event_category: 'listicle'
    }
    date_range = DateRange.from_project_start
    emotional_report = EmotionalReport.new(date_range, current_user, options)
    behavioural_report = BehaviouralReport.new(date_range, current_user, emotional_report, options)
    cognitive_report = CognitiveReport.new(date_range, current_user, options)
    @report = {
        emotional: emotional_report,
        behavioural: behavioural_report,
        cognitive: cognitive_report
    }

    unless @listicle
      skip_authorization
      return head 404
    end
    authorize @listicle
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
    @listicle = current_user.listicles.find params[:listicle_id]
    authorize @listicle
  end

  def listicle_params
    params.require(:listicle).permit :intro, :footer, :item_separator_color, :vote_count_color, :arrows_default_color,
                                     :arrows_on_hover_color, :arrows_selected_color,
                                     :questions_attributes => [:body, :_destroy, :id]
  end

  def redirect_to_index
    redirect_to listicles_path, only_path: true
  end

  def response_params
    {is_up: params[:is_up] == 'true'}
  end
end