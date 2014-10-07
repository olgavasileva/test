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
    redirect_to questions_path if current_user.present?
  end

  # For demo only
  def gallery
  end

private

  def find_recent_questions
    @recent_questions ||= Question.order("created_at DESC").limit(2)
  end
end
