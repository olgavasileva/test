class PagesController < ApplicationController
  before_action :find_recent_questions

  layout "clean_canvas"

  def home
  	if user_signed_in?
      @micropost = current_user.microposts.build
      @feed_items = current_user.feed
      @questions_answered = current_user.answered_questions
  	end

    @categories = Category.order(:name)
    @feed_questions = Question.order("created_at DESC")
  end

  def help
  end

  def about
  end

  def contact
  end

  def test
    # render layout: false
  end

private

  def find_recent_questions
    @recent_questions ||= Question.order("created_at DESC").limit(2)
  end
end
