class StaticPagesController < ApplicationController
  def home
  	if signed_in?
      @micropost = current_user.microposts.build
      @feed_items = current_user.feed
      @questions_answered = current_user.answered_questions
  	end
  end

  def help
  end

  def about
  end

  def contact
  end
end
