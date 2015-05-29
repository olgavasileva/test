class ShortLinksController < ActionController::Base

  def latest_question
    question = Question.publik.active.order(created_at: :desc).first
    redirect_to web_app_question_url(question)
  end

  private

  def web_app_question_url(question)
    "#{ENV['WEB_APP_URL']}/#/app/questions/#{question.id}"
  end
end
