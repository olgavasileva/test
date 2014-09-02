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

    @campaign_data = [
      { label: "Targeted Reach", value: 50991 },
      { label: "Views", value: 40792 },
      { label: "Engagements", value: 36713 },
      { label: "Completes", value: 35612 },
      { label: "Skips", value: 366 },
      { label: "Comments", value: 2149 },
      { label: "Shares", value: 1973 }
    ]

    @dummy_response_data = [
      { completed: true, response_url: '#', response_id: 201798, respondent_url: '#', respondent_name:"timmyo", date: 0.days.ago},
      { completed: true, response_url: '#', response_id: 201799, respondent_url: '#', respondent_name:"bobbyj", date: 30.seconds.ago},
      { completed: true, response_url: '#', response_id: 201812, respondent_url: '#', respondent_name:"jimmyz", date: 32.seconds.ago},
      { completed: true, response_url: '#', response_id: 201824, respondent_url: '#', respondent_name:"jamest", date: 39.seconds.ago},
      { completed: true, response_url: '#', response_id: 201890, respondent_url: '#', respondent_name:"bobd", date: 41.seconds.ago},
      { completed: false, response_url: '#', response_id: 201891, respondent_url: '#', respondent_name:"sammyd", date: 51.seconds.ago},
      { completed: true, response_url: '#', response_id: 201997, respondent_url: '#', respondent_name:"jamiec", date: 102.seconds.ago},
      { completed: false, response_url: '#', response_id: 201999, respondent_url: '#', respondent_name:"sophia", date: 112.seconds.ago},
      { completed: false, response_url: '#', response_id: 202020, respondent_url: '#', respondent_name:"johnny", date: 122.seconds.ago},
      { completed: true, response_url: '#', response_id: 202024, respondent_url: '#', respondent_name:"julia", date: 234.seconds.ago},
      { completed: true, response_url: '#', response_id: 202045, respondent_url: '#', respondent_name:"stacy", date: 345.seconds.ago},
      { completed: true, response_url: '#', response_id: 202089, respondent_url: '#', respondent_name:"frederick", date: 890.seconds.ago},
      { completed: false, response_url: '#', response_id: 202102, respondent_url: '#', respondent_name:"wylie", date: 991.seconds.ago},
      { completed: true, response_url: '#', response_id: 202189, respondent_url: '#', respondent_name:"stevej", date: 1234.seconds.ago},
      { completed: true, response_url: '#', response_id: 202212, respondent_url: '#', respondent_name:"timc", date: 2345.seconds.ago}
    ]

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
