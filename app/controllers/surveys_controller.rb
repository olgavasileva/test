class SurveysController < ApplicationController
  layout "../surveys/layout"

  skip_before_action :authenticate_user!, :find_recent_questions

  before_action :preload_and_authorize

  protect_from_forgery with: :null_session

  helper_method :next_question_path, :current_ad_unit_user

  rescue_from(Pundit::NotAuthorizedError) do
    render :invalid_survey
  end

  rescue_from(ActiveRecord::ActiveRecordError) do |ex|
    Airbrake.notify_or_ignore(ex)
    render :invalid_survey
  end

  def start
    @question = survey.questions.first
    @question.try :viewed!
    render :question
  end

  def question
    @question = survey.questions.find(params[:question_id])
    @question.try :viewed!
    render :question
  end

  def create_response
    @question = survey.questions.find(params[:question_id])
    @response = @question.responses.create!(response_params) do |r|
      r.user = current_ad_unit_user
    end

    render :question
  end

  def thank_you
    render :thank_you, layout: false
  end

  def quantcast
    DataProvider.where(name: 'quantcast').first_or_create
    demographic = current_ad_unit_user.demographics.quantcast.first_or_create
    demographic.update_from_provider_data!('quantcast', '1.0', quantcast_data)
    head :ok
  end

  private

    def survey
      @survey ||= Survey.find_by!( uuid: params[:survey_uuid])
    end

    def ad_unit
      @ad_unit ||= AdUnit.find_by!(name: (params[:unit_name] || AdUnit::DEFAULT_NAME))
    end

    def preload_and_authorize
      survey
      ad_unit
      authorize survey
    end

    def response_params
      # Using 'response' as the base param with all the parts allowed for various resposne types
      # Relying on response validation to sort out bad params
      params.require(:response).permit(:choice_id, :choice_ids, :text)
    end

    def current_ad_unit_user
      @ad_unit_user ||= begin
        ad_unit_user = if cookies.signed[:eu_user]
          Respondent.find_by(id: cookies.signed[:eu_user])
        end

        ad_unit_user = Anonymous.create!(auto_feed: false) unless ad_unit_user
        cookies.permanent.signed[:eu_user] = ad_unit_user.id
        ad_unit_user
      end
    end

    def next_question_path question
      next_question = survey.next_question(question)
      if next_question
        qp_question_path(survey.uuid, @ad_unit.name, next_question.id)
      else
        qp_thank_you_path(survey.uuid, @ad_unit.name)
      end
    end
end
