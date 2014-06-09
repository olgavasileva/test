class StaticPagesController < ApplicationController
  def home
  	if signed_in?
  		@micropost = current_user.microposts.build
  		@feed_items = current_user.feed.paginate(page: params[:page])
      @questions_answered = current_user.answered_questions.paginate(page: params[:page])
  	end
  end

  def help
  end

  def about
  end

  def contact
  end
end
