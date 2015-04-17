class ShortLinksController < ActionController::Base

  def latest_question
    question = Question.publik.active.order(created_at: :desc).first
    redirect_to web_app_question_url(question)
  end

  def app_question
    question = Question.find(params[:id])
    redirect_to web_app_question_url(question)
  end

  private

  def web_app_question_url(question)
    app_host = if Rails.env.production?
      "app.statisfy.co"
    elsif Rails.env.labs?
      "labs.app.statisfy.co"
    else
      "app." + request.host
    end

    URI.join(root_url(host: app_host), "/#/app/questions/#{question.id}").to_s
  end
end
