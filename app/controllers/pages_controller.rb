class PagesController < ApplicationController
  skip_before_action :authenticate_user!
  skip_after_action :verify_authorized
  before_action :find_recent_questions

  def help
  end

  def about
  end

  def contact
  end

  def test
    # render layout: false
  end

  # For testing studio setup
  def studio
    @response = StudioQuestion.first.responses.new user: current_user
  end

  def welcome
    @community = Community.find_by id:params[:community_id] if params[:community_id]

    if user_signed_in?
      redirect_to questions_path
    else
      current_user.update_feed_if_needed!

      @questions = if current_user.anonymous?
        Question.active.publik.order("created_at DESC").paginate(page: 1, per_page: 8)
      else
        current_user.feed_questions.latest.paginate(page: 1, per_page: 8)
      end

      render :welcome, layout: 'welcome'
    end
  end

  def rpush_check
    begin
      pid=IO.read(File.join(Rails.root.to_s, 'tmp', 'pids', 'rpush.pid').to_s).to_i
      Process.kill 0, pid
      render text: "rpush is running"
    rescue
      if params[:start].present?
        `bundle exec rpush start -e #{Rails.env}`
        render text: "started rpush - it was not running"
      else
        render text: "rpush is not running"
      end
    end
  end

  # For demo only
  def gallery
  end

private

  def find_recent_questions
    @recent_questions ||= Question.order("created_at DESC").limit(2)
  end
end
