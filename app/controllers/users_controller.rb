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

  def dashboard
    @user = User.find params[:id]
    authorize @user

    # TODO - lazy load this data
    @campaign_data = [
      { label: "Targeted Reach", value: @user.questions.map{|q| q.targeted_reach }.sum },
      { label: "Views", value: @user.questions.sum(:view_count) },
      { label: "Engagements", value: @user.questions.sum(:start_count) },
      { label: "Completes", value: @user.questions.map{|q| q.response_count }.sum },
      { label: "Skips", value: @user.questions.map{|q| q.skip_count }.sum },
      { label: "Comments", value: @user.questions.map{|q| q.comment_count }.sum  },
      { label: "Shares", value: @user.questions.map{|q| q.share_count }.sum  }
    ]

    # TODO - lazy load this data
    @recent_question_actions = QuestionAction.recent_actions(@user, Time.now - 6.hours)

    @dummy_comment_data = [
      { email: "james@kirk.com", name: "Jim", url: '#', campaign_name: "Campaign 1", campaign_url: '#', text: "This was an awesome question!", date: 5.minutes.ago },
      { email: "scotty@engineering.com", name: "James", url: '#', campaign_name: "Campaign 1", campaign_url: '#', text: "This was another awesome question!", date: 7.minutes.ago },
      { email: "leonard@mccoy.com", name: "Leonard", url: '#', campaign_name: "Campaign 1", campaign_url: '#', text: "This was an great question!", date: 12.minutes.ago },
      { email: "uhura@thebridge.com", name: "Nyota", url: '#', campaign_name: "Campaign 1", campaign_url: '#', text: "This was asked just in time!", date: 23.minutes.ago },
      { email: "hikaru@sulu.com", name: "Hikaru", url: '#', campaign_name: "Campaign 1", campaign_url: '#', text: "Who came up with this one?!", date: 45.minutes.ago },
      { email: "spock@vulcan.com", name: "Spock", url: '#', campaign_name: "Campaign 1", campaign_url: '#', text: "Please ask more like this!", date: 123.minutes.ago },
      { email: "patrick@stewart.com", name: "Captain", url: '#', campaign_name: "Campaign 1", campaign_url: '#', text: "What a rare thing to konw about!", date: 1234.minutes.ago }
    ]

    @dummy_complete_data = [
      { email: "arthur@fillingstation.com", date: 1.week.ago, response: "That's what she said.", response_url: '#', name: "Fonzie", url: '#' },
      { email: "ralph@malph.com", date: 2.weeks.ago, response: "That's what he said.", response_url: '#', name: "Ralph", url: '#' },
      { email: "ritchie@cunningham.com", date: 3.weeks.ago, response: "That's what I always say.", response_url: '#', name: "Richard", url: '#' },
      { email: "jonie@cunningham.com", date: 2.months.ago, response: "Wait, who said that?.", response_url: '#', name: "Jonie", url: '#' }
    ]

    render layout: "pixel_admin"
  end
end
