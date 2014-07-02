class PagesController < ApplicationController
  before_action :find_recent_questions

  layout "clean_canvas"

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
