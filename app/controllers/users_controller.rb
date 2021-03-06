require 'will_paginate/array'

class UsersController < ApplicationController

  after_action :read_all_messages, only: :show, if: Proc.new { @tab == 'notifications' }
  before_action :load_and_authorize_user, except: [:profile]
  before_action :set_sample_data,
    only: [:analytics, :question_analytics, :demographics]
  before_action :find_question,
    only: [:analytics, :question_analytics, :demographics]
  before_action :set_days_ago, only: [:behavioural_report, :cognitive_report, :publisher_dashboard]

  rescue_from Pundit::NotAuthorizedError do
    head :unauthorized
  end

  def profile
    @user = current_user
    authorize @user
  end

  def show
    default_tab = @user == current_user ? 'notifications' : 'questions'
    @tab = params.fetch(:tab, default_tab)

    case @tab
    when 'notifications'
      authorize @user, :show_notifications?

      @notifications = @user.messages.page(params[:page])
    when 'questions'
      @subtab = params.fetch(:subtab, 'asked')

      case @subtab
      when 'asked'
        @questions = @user.questions.page(params[:page])
      when 'answered'
        @questions = @user.answered_questions.page(params[:page])
      when 'commented'
        # todo: optimize
        question_ids = @user.comments.map{|c| c.question.id if c.question.present?}
        @questions = Question.where(id: question_ids).page(params[:page])
      end
    when 'communities'
      default_subtab = @user == current_user ? 'join' : 'my'
      @subtab = params.fetch(:subtab, default_subtab)

      case @subtab
      when 'join'
        authorize @user, :show_join_communities?

        @communities = Community.search(name_cont: params[:search_text]).result
      when 'create'
        authorize @user, :show_create_community?
      when 'my'
        @member_communities = @user.membership_communities
        @communities = @user.communities
      end
    when 'followers'
      @followers = @user.followers.page(params[:page])
    when 'following'
      # todo: optimize
      leaders = @user.leaders.search(name_cont: params[:search_text]).result
      @users = leaders
      if @user == current_user
        unleaders = User.where.not(id: leaders + [current_user]).search(name_cont: params[:search_text]).result
        @users += unleaders
      end
    end
  end

  def follow
    current_user.follow! @user
    flash[:notice] = "Followed #{@user.name}."
    redirect_to :back
  end

  def unfollow
    current_user.leaders.delete(@user)
    flash[:notice] = "Stopped following #{@user.name}."
    redirect_to :back
  end

  def dashboard
    return publisher_dashboard if @user.publisher?
    # TODO - lazy load this data
    reach = @user.questions.sum(:view_count)
    targeted_reach = @user.questions.map{|q| q.targeted_reach.to_i }.sum
    viral_reach = reach - targeted_reach
    completes = @user.questions.map{|q| q.response_count }.sum
    shares = @user.share_count

    @campaign_data = [
      { label: "Reach", value: reach },
      { label: "Completes", value: completes },
      { label: "Shares", value: shares }
    ]

    if reach != 0
      @viral_rate = viral_reach.to_f / reach
      @complete_rate = completes.to_f / reach
    end
    dates = (0..29).to_a.reverse.map{ |days_ago| Date.today - days_ago }
    @responses_by_day_data = dates.zip(DailyAnalytic.fetch_array(:responses, dates, @user))

    @reach_today = DailyAnalytic.fetch(:views, Date.today, @user)

    @targeted_reach = targeted_reach
    @viral_reach = viral_reach
    @reach_data_points = DailyAnalytic.fetch_array(:views, dates, @user)

    render layout: "pixel_admin"
  end

  def recent_responses
    @recent_responses = @user.responses_to_questions
                            .includes(:user, :question)
                            .order("responses.created_at DESC").kpage(params[:page]).per(5)
  end

  def recent_comments
    @recent_comments = @user.comments_on_questions_and_responses
      .includes(:user, :commentable)
      .order("comments.created_at DESC")
      .kpage(params[:page])
      .per(5)
  end

  def publisher_question_packs
    @surveys = current_user.valid_surveys
    @analytics = QuestionPackReport.new(DateRange.from_project_start, current_user)
    render layout: 'pixel_admin'
  end

  def behavioural_report
    emotional_report = EmotionalReport.new(@date_range, current_user)
    behavioural_report = BehaviouralReport.new(@date_range, current_user, emotional_report)
    @report = {emotional: emotional_report, behavioural: behavioural_report}
    render partial: 'users/dashboard/publisher/behavioural_and_cognitive_panels', layout: false
  end

  def cognitive_report
    cognitive_report = CognitiveReport.new(@date_range, current_user)
    render partial: 'users/dashboard/publisher/cognitive_panel', locals: {report: cognitive_report}
  end

  def publisher_dashboard
    render 'publisher_dashboard', layout: 'pixel_admin'
  end

  def new_campaign
    # When we're creating a question from the enterprise dashboard, keep
    # track so we can target properly
    session[:use_enterprise_targeting] = true
    redirect_to [:question_types]
  end

  def analytics
    respond_to do |format|
      format.html do
        @demographics = DemographicSummary.aggregate_data_for_question(@question, us_only: true) if @question
        render layout: "pixel_admin"
      end

      format.csv do
        send_data DemographicCSV.export(@question, us_only: true)
      end

      format.text do
        render text: DemographicCSV.export(@question, us_only: true)
      end
    end
  end

  def question_analytics
    @demographics = DemographicSummary.aggregate_data_for_question(@question, us_only: true) if @question

    render layout: false
  end

  def demographics
    if @question
      @demographics = if params[:choice_id]
        @choice = @question.choices.find(params[:choice_id])
        DemographicSummary.aggregate_data_for_choice(@choice, us_only: true)
      else
        DemographicSummary.aggregate_data_for_question(@question, us_only: true)
      end

      render layout: false
    else
      render text: "Question Not Accessable"
    end
  end

  # search "any question" where "any question" is defined as any public question that is
  # not created by a user that is marked "Pro"
  # or any question owned by the current pro user
  def question_search
    search_term = params[:term]

    my_questions = @user.questions.select([:id, :title, :user_id]).where("title like ?", "%#{search_term}%")
    public_non_pro_questions = Question.publik.select([:id, :title, :user_id]).where("title like ?", "%#{search_term}%").limit(200).select{|q| !q.user.is_pro?}

    questions = my_questions + public_non_pro_questions

    response = questions.map{|q| {id:q.id, title:q.title, load_url:view_context.question_analytics_user_url(@user, question_id:q)}}.sort{|a,b| a[:title] <=> b[:title]}
    render json:response
  end

  def account
    render layout: "pixel_admin"
  end

  def update
    if @user.update_with_password user_params
      # Sign in the user by passing validation in case their password changed
      sign_in @user, bypass: true
      flash[:notice] = "Account Settings Changed"
      redirect_to [:account, @user]
    else
      render "account", layout: "pixel_admin"
    end
  end

  def avatar
    if @user.avatar.present?
      redirect_to @user.avatar.image.web.url
    else
      redirect_to gravatar_url(@user.email, default: :identicon)
    end
  end

  def new_question
    render layout: 'pixel_admin'
  end

  private

    def load_and_authorize_user
      @user = User.find(params[:id])
      authorize @user
    end

    def set_sample_data
      session[:use_sample_demographics_data] = params[:sample].to_s.true? if params[:sample]
      DemographicSummary.use_sample_data = session[:use_sample_demographics_data]
    end

    def find_question
      @question = if params[:question_id]
        candidate = Question.find_by(id: params[:question_id])
        candidate if candidate.user == @user || (candidate.public? && !candidate.user.is_pro?)
      end
    end

    def user_params
      params.required(:user).permit(
        :company_name, :email, :gender, :birthdate,
        :current_password, :password, :password_confirmation
      )
    end

    def read_all_messages
      @user.read_all_messages
    end

    def set_days_ago
      @days_ago = if params[:days_ago]
                    params[:days_ago].to_i
                  else
                    30 # month
                  end
      @date_range = DateRange.new(Date.today - @days_ago.days)
    end
end
