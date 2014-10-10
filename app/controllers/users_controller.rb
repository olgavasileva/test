require 'will_paginate/array'

class UsersController < ApplicationController
  def profile
    @user = current_user
    authorize @user
  end

  def show
    @user = User.find params[:id]
    authorize @user

    default_tab = @user == current_user ? 'notifications' : 'questions'
    @tab = params.fetch(:tab, default_tab)

    case @tab
    when 'notifications'
      authorize @user, :notifications?

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
        question_ids = @user.comments.map{|c| c.question.id}
        @questions = Question.where(id: question_ids).page(params[:page])
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
    @user = User.find params[:id]
    authorize @user

    current_user.follow! @user

    alerts[:notice] = "Followed #{@user.name}."

    redirect_to :back
  end

  def unfollow
    @user = User.find params[:id]
    authorize @user

    current_user.leaders.delete(@user)

    flash[:notice] = "Stopped following #{@user.name}."
    redirect_to :back
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
    reach = @user.questions.sum(:view_count)
    targeted_reach = @user.questions.map{|q| q.targeted_reach.to_i }.sum
    viral_reach = reach - targeted_reach
    engagements = @user.questions.sum(:start_count)
    completes = @user.questions.map{|q| q.response_count }.sum
    skips = @user.questions.map{|q| q.skip_count }.sum
    comments = @user.questions.map{|q| q.comment_count }.sum
    shares = @user.questions.map{|q| q.share_count }.sum

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
    @user = User.find params[:id]
    authorize @user

    @recent_responses = @user.responses_to_questions.order("responses.created_at DESC").kpage(params[:page]).per(5)
  end

  def recent_comments
    @user = User.find params[:id]
    authorize @user

    @recent_comments = @user.comments_on_questions_and_responses.order("comments.created_at DESC").kpage(params[:page].per(5))
  end

  def campaigns
    @user = User.find params[:id]
    authorize @user

    @questions = @user.questions.active

    render layout: "pixel_admin"
  end

  def analytics
    @user = User.find params[:id]
    authorize @user

    @question = Question.find params[:question_id] if params[:question_id]

    render layout: "pixel_admin"
  end

  def account
    @user = User.find params[:id]
    authorize @user

    render layout: "pixel_admin"
  end

end
