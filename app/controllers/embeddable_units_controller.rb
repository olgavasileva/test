class EmbeddableUnitsController < ApplicationController
  layout "embeddable_unit"

  skip_before_action :authenticate_user!

  before_action :authorize_embeddable_unit
  after_action :allow_iframe

  rescue_from Pundit::NotAuthorizedError do
    render :invalid_unit
  end

  def start_survey
    cookies[:euuid] = {value: embeddable_unit.uuid, expires: 1.day.from_now}
    redirect_to new_question_response_path(@embeddable_unit.survey.questions.first.id)
  end

  def summary
    @response = Response.find params[:response_id]
  end

  def next_question
    @question = Question.find params[:question_id]
    next_question = embeddable_unit.survey.next_question(@question)

    if next_question
      redirect_to new_question_response_path(next_question)
    else
      redirect_to embeddable_unit_thank_you_path(cookies[:euuid])
    end
  end

  def thank_you
    cookies.delete :euuid
  end

  private

  def embeddable_unit
    @embeddable_unit ||= EmbeddableUnit.find_by(uuid: params[:embeddable_unit_uuid])
  end

  def authorize_embeddable_unit
    authorize embeddable_unit
  end
end
