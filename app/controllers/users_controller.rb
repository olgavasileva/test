require 'will_paginate/array'

class UsersController < ApplicationController

  after_action :read_all_messages, only: :show, if: Proc.new { @tab == 'notifications' }
  before_action :load_and_authorize_user, except: [:profile]
  before_action :set_sample_data,
    only: [:analytics, :question_analytics, :demographics]

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
    # TODO - lazy load this data
    reach = @user.questions.sum(:view_count)
    targeted_reach = @user.questions.map{|q| q.targeted_reach.to_i }.sum
    viral_reach = reach - targeted_reach
    engagements = @user.questions.sum(:start_count)
    completes = @user.questions.map{|q| q.response_count }.sum
    skips = @user.questions.map{|q| q.skip_count }.sum
    comments = @user.questions.map{|q| q.comment_count }.sum
    shares = @user.questions.map{|q| q.share_count.to_i }.sum


    @campaign_data = [
      { label: "Reach", value: reach },
      { label: "Engagements", value: engagements },
      { label: "Completes", value: completes },
      { label: "Skips", value: skips },
      { label: "Comments", value: comments },
      { label: "Shares", value: shares }
    ]

    if reach != 0
      @viral_rate = viral_reach.to_f / reach
      @engagement_rate = engagements.to_f / reach
      @complete_rate = completes.to_f / reach
    end

    @responses_by_day_data = (0..29).to_a.reverse.map{|days_ago| {day: (Date.today - days_ago).to_formatted_s(:sql), v: DailyAnalytic.fetch(:responses, Date.today - days_ago, @user)}}

    engagements_yesterday = DailyAnalytic.fetch(:starts, Date.today - 1, @user)
    engagements_day_before = DailyAnalytic.fetch(:starts, Date.today - 2, @user)
    @engagement_increase_rate = engagements_yesterday.to_f / engagements_day_before - 1 unless engagements_day_before == 0
    @engagement_data_points = (0..29).to_a.reverse.map{|days_ago| DailyAnalytic.fetch(:starts, Date.today - days_ago, @user)}

    @reach_today = DailyAnalytic.fetch(:views, Date.today, @user)

    @targeted_reach = targeted_reach
    @viral_reach = viral_reach
    @reach_data_points = (0..29).to_a.reverse.map{|days_ago| DailyAnalytic.fetch(:views, Date.today - days_ago, @user)}

    render layout: "pixel_admin"
  end

  def recent_responses
    @recent_responses = @user.responses_to_questions.order("responses.created_at DESC").kpage(params[:page]).per(5)
  end

  def recent_comments
    @recent_comments = @user.comments_on_questions_and_responses
      .order("comments.created_at DESC")
      .kpage(params[:page])
      .per(5)
  end

  def campaigns
    @questions = @user.questions.active
    render layout: "pixel_admin"
  end

  def new_campaign
    # When we're creating a question from the enterprise dashboard, keep
    # track so we can target properly
    session[:use_enterprise_targeting] = true
    redirect_to [:question_types]
  end

  def analytics
    if params[:question_id]
      @question = @user.questions.find(params[:question_id])
    end

    respond_to do |format|
      format.html do
        @demographics = Demographic.aggregate_data_for_question(@question)
        render layout: "pixel_admin"
      end

      format.csv do
        send_data DemographicCSV.export(@question)
      end
    end
  end

  def question_analytics
    if params[:question_id]
      @question = @user.questions.find(params[:question_id])
      @demographics = Demographic.aggregate_data_for_question(@question)
    end

    render layout: false
  end

  def demographics
    @question = @user.questions.find(params[:question_id])

    @demographics = if params[:choice_id]
      @choice = @question.choices.find(params[:choice_id])
      Demographic.aggregate_data_for_choice(@choice)
    else
      Demographic.aggregate_data_for_question(@question)
    end

    render layout: false
  end

  def question_search
    search_term = params[:term]
    questions = @user.questions.where("title like ?", "%#{search_term}%").select([:id, :title])
    response = questions.map{|q| {id:q.id, title:q.title, load_url:view_context.question_analytics_user_url(@user, question_id:q)}}
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

  private

    def load_and_authorize_user
      @user = User.find(params[:id])
      authorize @user
    end

    def set_sample_data
      session[:use_sample_demographics_data] = params[:sample].to_s.true? if params[:sample]
      Demographic.use_sample_data = session[:use_sample_demographics_data]
    end

    def user_params
      params.required(:user).permit(
        :company_name, :email, :gender, :birthdate,
        :current_password, :password, :password_confirmation
      )
    end
end
