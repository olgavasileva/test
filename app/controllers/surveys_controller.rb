class SurveysController < ApplicationController
  layout "../surveys/layout"

  skip_before_action :authenticate_user!, :find_recent_questions

  before_action :migrate_user_cookie
  before_action :preload_and_authorize

  protect_from_forgery with: :null_session

  helper_method \
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

  def start
    store_query_params
    reset_session_responses

    @question = question_scope.first
    @question.try :viewed!

    render :question
  end

  def question
    @question = question_scope.find(params[:question_id])

    # Find the response if they responded in this session (since the last time they started)
    @response = session_response_for_question @question

    @question.try :viewed!
    render :question
  end

  def create_response
    @question = question_scope.find(params[:question_id])
    @response = @question.responses.create!(response_params.merge(source: 'embeddable')) do |r|
      r.user = current_ad_unit_user
    end

    remember_session_response @response

    render :question
  end

  def thank_you
    @thank_you_html = @survey.parsed_thank_you_html stored_query_params
    render :thank_you, layout: false
  end

  def quantcast
    DataProvider.where(name: 'quantcast').first_or_create
    demographic = current_ad_unit_user.demographics.quantcast.first_or_create
    demographic.update_from_provider_data!('quantcast', '1.0', quantcast_data)
    head :ok
  end

  private

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
      params.require(:response).permit(:choice_id, :text, choice_ids: [])
    end

    def question_class
      classes = [@question.try(:class).try(:name)]
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

    def previous_question_path(question)
      return @previous_question if defined?(@previous_question)
      @prev_question = if prev_question = survey.previous_question(question)
        qp_question_path(survey.uuid, ad_unit.name, prev_question.id)
      end
    end

    def next_question_path(question)
      @next_question = if next_question = survey.next_question(question)
        qp_question_path(survey.uuid, @ad_unit.name, next_question.id)
      else
        qp_thank_you_path(survey.uuid, @ad_unit.name)
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

    def store_query_params
      session[survey.uuid] = request.query_parameters
    end

    def stored_query_params
      session[survey.uuid]
    end

    def meta_data_for(image)
      {
        id: image.id,
        url: image.web_image_url,
        meta: image.ad_unit_info(@ad_unit.name).try(:meta_data)
      }.to_json
    end
end
