class EmbeddableUnitsController < ApplicationController
  layout "embeddable_unit"

  protect_from_forgery with: :null_session

  helper_method :next_question_url, :current_embed_user

  skip_before_action :authenticate_user!, :find_recent_questions

  before_action :migrate_user_cookie
  before_action :authorize_embeddable_unit
  after_action :allow_iframe

  rescue_from(Pundit::NotAuthorizedError) do
    render :invalid_unit
  end

  rescue_from(ActiveRecord::ActiveRecordError) do |ex|
    Airbrake.notify_or_ignore(ex)
    render :invalid_unit
  end

  def start_survey
    @question = embeddable_unit.questions.first
    @question.try :viewed!
    render :question
  end

  def survey_question
    @question = embeddable_unit.questions.find(params[:question_id])
    @question.try :viewed!
    render :question
  end

  def survey_response
    @auto_advance = Setting.fetch_value('embeddable_unit_auto_forward')
    @question = embeddable_unit.questions.find(params[:question_id])
    @response = @question.responses.create!(response_params.merge({source: 'embeddable'})) do |r|
      r.user = current_embed_user
    end

    render :summary
  end

  def thank_you
    render :thank_you
  end

  def quantcast
    DataProvider.where(name:'quantcast').first_or_create
    demo = current_embed_user.demographics.quantcast.first_or_create
    demo.ip_address = request.remote_ip
    demo.user_agent = request.env['HTTP_USER_AGENT']
    demo.update_from_provider_data!('quantcast', '1.0', quantcast_data)
    head :ok
  end

  private

  def embeddable_unit
    @embeddable_unit ||= EmbeddableUnit.find_by!(uuid: params[:embeddable_unit_uuid])
  end

  def migrate_user_cookie
    # Migrate old cookie from statisfy subdomain to base domain
    if Rails.env.production? && ((user_id = cookies.signed[:eu_user]))
      cookies.delete(:eu_user, domain: request.host)
      store_eu_user(user_id)
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

  def current_embed_user
    @embed_user ||= begin
      embed_user = cookie_user || Anonymous.create!(auto_feed: false)
      store_eu_user(embed_user.id)
      embed_user
    end
  end

  def authorize_embeddable_unit
    authorize embeddable_unit
  end

  def response_params
    params.require(:image_choice_response).permit(:choice_id)
  end

  def quantcast_data
    params[:quantcast]
  end

  def next_question_url(question)
    next_question = embeddable_unit.survey.next_question(question)
    if next_question
      embeddable_unit_question_path(embeddable_unit.uuid, next_question.id)
    else
      embeddable_unit_thank_you_path
    end
  end
end
