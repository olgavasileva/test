class SurveysController < ApplicationController
  layout "surveys"

  skip_before_action :authenticate_user!, :find_recent_questions

  before_action :set_expiration_headers, only: [:start]
  before_action :migrate_user_cookie, except: [:question_viewed]
  before_action :preload_and_authorize
  after_action :allow_iframe, except: [:question_viewed]

  protect_from_forgery with: :null_session

  helper_method \
    :settings,
    :previous_question_path,
    :next_question_path,
    :cookie_user,
    :current_ad_unit_user,
    :question_class,
    :meta_data_for

  rescue_from(Pundit::NotAuthorizedError) do
    render :invalid_survey
  end

  rescue_from(ActiveRecord::ActiveRecordError) do |ex|
    Airbrake.notify_or_ignore(ex)
    render :invalid_survey, layout: false
  end

  def question_viewed
    question = question_scope.find(params[:question_id])
    question.try :viewed!
    render text: "OK #{question.try :id}"
  end

  def start
    @original_referrer = @referrer = request.referrer
    # session[:survey_original_referrer] = @original_referrer
    @thank_you_html = survey.parsed_thank_you_html(request.query_parameters).html_safe || default_thank_you
    @question = question_scope.first
  end

  def create_response
    @question = question_scope.find(params[:question_id])

    @response = @question.responses.create!(response_params.merge(source: 'embeddable')) do |r|
      r.user = current_ad_unit_user
    end
    @original_referrer = @response.original_referrer

    # Whenever they answer the first question, reset the responses so they can answer them all again
    # We can't do this in start since it may be cached on cloudfront
    reset_session_responses if @question == question_scope.first

    # Remember that they answered this question so we show summary data if the hit the back button
    remember_session_response @response

    render :question
  end

  def question
    @question = question_scope.find(params[:question_id])

    # Find the response if they responded in this session (since the last time they started)
    @response = session_response_for_question @question
    @original_referrer = params[:original_referrer]
    # @original_referrer = session[:survey_original_referrer]
  end

  def thank_you
    @referrer = params[:original_referrer]
    # @referrer = session[:survey_original_referrer]
    @sample_surveys = sample_surveys
    reset_session_responses
    render :thank_you, layout: false
  end

  def quantcast
    DataProvider.where(name: 'quantcast').first_or_create
    demographic = current_ad_unit_user.demographics.quantcast.first_or_create
    demographic.ip_address = request.remote_ip
    demographic.user_agent = request.env['HTTP_USER_AGENT']
    demographic.update_from_provider_data!('quantcast', '1.0', quantcast_data)
    head :ok
  end

  def default_thank_you
    @referrer = params[:original_referrer]
    # @referrer = session[:survey_original_referrer]
    @sample_surveys = sample_surveys
    render_to_string partial: 'surveys/default_thank_you'
  end

  private

    def sample_surveys
      SampleSurveySearcher.new(current_user, @survey, @referrer || request.referrer || '',
                               @ad_unit.related_surveys_count).sample_surveys
    end

    def settings
      @survey_settings ||= Setting.fetch_values(
        'ad_unit_expires',
        'ad_cache_control',
        'embeddable_unit_cta_min_start',
        'embeddable_unit_cta_max_start',
        'embeddable_unit_cta_fade_speed',
        'embeddable_unit_cta_duration',
        'embeddable_unit_cta_repeat',
        'embeddable_unit_feedback_duration',
        'embeddable_unit_vote_text',
        'embeddable_unit_vote_bounce_speed'
      )
    end

    def set_expiration_headers
      if settings[:ad_unit_expires]
        headers["Expires"] = settings[:ad_unit_expires]
      end

      if settings[:ad_cache_control]
        headers["Cache-Control"] = settings[:ad_cache_control]
      end
    end

    def quantcast_data
      params[:quantcast]
    end

    def question_scope
      survey.questions.eager_load(:background_image, :choices)
    end

    def survey
      @survey ||= Survey.eager_load(questions_surveys: [:question])
        .order('questions_surveys.position ASC')
        .find_by!(uuid: params[:survey_uuid])
    end

    def ad_unit
      @ad_unit ||= begin
        ad_unit_name = params[:unit_name] || AdUnit::DEFAULT_NAME
        AdUnit.find_by!(name: ad_unit_name)
      end
    end

    def preload_and_authorize
      survey
      ad_unit
      authorize survey
    end

    def response_params
      # Using 'response' as the base param with all the parts allowed for various response types
      # Relying on response validation to sort out bad params
      params.require(:response).permit(:choice_id, :text, :original_referrer, choice_ids: [])
    end

    def question_class
      classes = if @question.try(:min_responses).to_i > 1
        ['MultipleChoiceQuestion']
      else
        [@question.try(:class).try(:name)]
      end

      classes.push "choices-#{@question.try(:choices).try(:length)}"
      classes.push('has-response') if @response
      classes.join(' ')
    end

    def migrate_user_cookie
      # Migrate old cookie from statisfy subdomain to base domain
      if Rails.env.production? && ((_user = cookies.signed[:eu_user]))
        cookies.delete(:eu_user, domain: request.host)
        store_eu_user(_user)
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

    def current_ad_unit_user
      @ad_unit_user ||= begin
        ad_unit_user = cookie_user || Anonymous.create!(auto_feed: false)
        store_eu_user(ad_unit_user.id)
        ad_unit_user
      end
    end

    def previous_question_path(question, original_referrer)
      @prev_question = if prev_question = survey.previous_question(question)
        qp_question_path(survey.uuid, ad_unit.name, prev_question.id, original_referrer: original_referrer)
      end
    end

    def next_question_path(question, original_referrer)
      @next_question = if next_question = survey.next_question(question)
        qp_question_path(survey.uuid, @ad_unit.name, next_question.id, original_referrer: original_referrer)
      else
        qp_thank_you_path(survey.uuid, @ad_unit.name, original_referrer: original_referrer)
      end
    end

    ##
    ## Helpers for storing and retrieving responses during one survey session
    ##

    def reset_session_responses
      session[:survey_response_ids] = {}
    end

    def session_response_for_question question
      session[:survey_response_ids] ||= {}
      response_id = session[:survey_response_ids][question.id]
      question.responses.where(user_id: current_ad_unit_user.id).find_by(id: response_id) if response_id
    end

    def remember_session_response response
      session[:survey_response_ids] ||= {}
      session[:survey_response_ids][response.question.id] = response.id
    end

    ##
    ## Helpers for storing and retrieving query params
    ##

    def meta_data_for(image)
      {
        id: image.id,
        url: image.web_image_url,
        meta: image.ad_unit_info(@ad_unit.name).try(:meta_data)
      }.to_json
    end
end
