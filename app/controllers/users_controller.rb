class UsersController < ApplicationController
  def profile
    @user = current_user
    authorize @user
  end

  def show
    @user = User.find params[:id]
    authorize @user
  end

  def follow
    @user = User.find params[:id]
    authorize @user

    current_user.follow! @user
  end

  def first_question
    @user = current_user
    authorize @user

    @user.feed_more_questions 10 if @user.feed_questions.count < 1

    question = @user.feed_questions.order('feed_items.created_at DESC').first

    if question
      redirect_to new_question_response_path(question)
    else
      flash[:alert] = "That was the last question, for now."
      redirect_to welcome_path
    end
  end

  def dashboard
    @user = User.find params[:id]
    authorize @user

    # TODO - lazy load this data
    targeted_reach = @user.questions.map{|q| q.targeted_reach }.sum
    views = @user.questions.sum(:view_count)
    engagements = @user.questions.sum(:start_count)
    completes = @user.questions.map{|q| q.response_count }.sum
    skips = @user.questions.map{|q| q.skip_count }.sum
    comments = @user.questions.map{|q| q.comment_count }.sum
    shares = @user.questions.map{|q| q.share_count }.sum

    @campaign_data = [
      { label: "Targeted Reach", value: targeted_reach },
      { label: "Views", value: views },
      { label: "Engagements", value: engagements },
      { label: "Completes", value: completes },
      { label: "Skips", value: skips },
      { label: "Comments", value: comments },
      { label: "Shares", value: shares }
    ]

    if targeted_reach != 0
      @view_rate = views.to_f / targeted_reach
      @engagement_rate = engagements.to_f / targeted_reach
      @complete_rate = completes.to_f / targeted_reach
    end

    @views_by_day_data = (0..6).to_a.reverse.map{|days_ago| {day: (Date.today - days_ago).to_formatted_s(:sql), v: DailyAnalytic.fetch(:views, Date.today - days_ago, @user)}}

    engagements_yesterday = DailyAnalytic.fetch(:starts, Date.today - 1, @user)
    engagements_day_before = DailyAnalytic.fetch(:starts, Date.today - 2, @user)
    @engagement_increase_rate = engagements_yesterday.to_f / engagements_day_before - 1 unless engagements_day_before == 0
    @engagement_data_points = (0..29).to_a.reverse.map{|days_ago| DailyAnalytic.fetch(:starts, Date.today - days_ago, @user)}

    @response_count = DailyAnalytic.fetch(:responses, Date.today, @user)

    @tweets_targeted = 36713
    @tweets_viral = 4079
    @tweet_data_points = [275,490,397,487,339,403,402,312,300]

    # TODO - lazy load this data
    @recent_question_actions = QuestionAction.recent_actions(@user, Time.now - 6.hours)
    @recent_responses_with_comments = @user.responses_with_comments.where("responses.created_at >= ?", Time.now - 6.hours)
    @recent_responses = @user.responses.where("responses.created_at >= ?", Time.now - 6.hours)

    render layout: "pixel_admin"
  end

  def campaigns
    @user = User.find params[:id]
    authorize @user

    @questions = @user.questions

    render layout: "pixel_admin"
  end

  def segments
    @user = User.find params[:id]
    authorize @user

    render layout: "pixel_admin"
  end

  def analytics
    @user = User.find params[:id]
    authorize @user

    render layout: "pixel_admin"
  end

  def account
    @user = User.find params[:id]
    authorize @user

    render layout: "pixel_admin"
  end

end
