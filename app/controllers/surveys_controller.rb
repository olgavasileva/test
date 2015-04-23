class SurveysController < ApplicationController
  layout "../surveys/layout"

  skip_before_action :authenticate_user!, :find_recent_questions

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

    @question = question_scope.first
    @question.try :viewed!

    if cookie_user.present?
      @response = @question.responses.where(user_id: cookie_user.id).last
    end

    render :question
  end

  def question
    @question = question_scope.find(params[:question_id])
    @response = @question.responses.where(user_id: current_ad_unit_user.id).last
    @question.try :viewed!
    render :question
  end

  def create_response
    @question = question_scope.find(params[:question_id])
    @response = @question.responses.create!(response_params.merge(source: 'embeddable')) do |r|
      r.user = current_ad_unit_user
    end

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
      # Migrate old cookie from statisfy subdomain to base domain
      if _user = cookies.signed[:eu_user]
        cookies.delete(:eu_user, domain: request.host)
        store_eu_user(_user)
      end

      survey
      ad_unit
      authorize survey
    end

    def response_params
      # Using 'response' as the base param with all the parts allowed for various resposne types
      # Relying on response validation to sort out bad params
      params.require(:response).permit(:choice_id, :text, choice_ids: [])
    end

    def question_class
      classes = [@question.try(:class).try(:name)]
      classes.push "choices-#{@question.try(:choices).try(:length)}"
      classes.push('has-response') if @response
      classes.join(' ')
    end

    def cookie_user
      return @cookie_user if defined?(@cookie_user)
      @cookie_user = if cookies.signed[:eu_user]
        Respondent.find_by(id: cookies.signed[:eu_user])
      end
    end

    def current_ad_unit_user
      @ad_unit_user ||= begin
        ad_unit_user = cookie_user
        ad_unit_user = Anonymous.create!(auto_feed: false) unless ad_unit_user
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

    def store_query_params
      session[survey.uuid] = request.query_parameters
    end

    def stored_query_params
      session[survey.uuid]
    end

    def store_eu_user(user_id)
      cookies.permanent.signed[:eu_user] = {
        value: user_id,
        domain: request.host.split('.').last(2).join('.')
      }
    end

    def meta_data_for(image)
      {
        id: image.id,
        url: image.web_image_url,
        meta: image.ad_unit_info(@ad_unit.name).try(:meta_data)
      }.to_json
    end
end
