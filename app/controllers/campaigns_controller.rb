class CampaignsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_and_authorize_user

  def index
    @surveys = current_user.valid_surveys.to_a
    @page = 1
    @per_page = 8
    @max_count = @surveys.length / @per_page
    if params[:page]
      @page = params[:page].to_i
    end
    @surveys = @surveys.slice((@page-1) * @per_page, @per_page)
    render 'users/campaigns/index', layout: 'pixel_admin'
  end

  def show
    @survey = current_user.surveys.find(params[:survey_id])
    options = {
        survey: @survey,
        question_ids: @survey.question_ids
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
    render 'users/campaigns/show', layout: 'pixel_admin'
  end

  private

  def load_and_authorize_user
    @user = Respondent.find(params[:id])
    if @user != current_user
      render :nothing => true, status: :unauthorized
    else
      skip_authorization
    end
  end
end
