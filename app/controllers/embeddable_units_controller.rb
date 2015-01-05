class EmbeddableUnitsController < ApplicationController
  skip_before_action :authenticate_user!
  after_action :allow_iframe

  layout "embeddable_unit"

  def start_survey
    @embeddable_unit = EmbeddableUnit.find_by uuid:params[:embeddable_unit_uuid]

    authorize @embeddable_unit

    if @embeddable_unit && @embeddable_unit.survey && @embeddable_unit.survey.questions.present?
      cookies[:euuid] = {value: params[:embeddable_unit_uuid], expires: Time.current + 1.day}
      redirect_to new_question_response_path(@embeddable_unit.survey.questions.first.id)
    end
  end

  def summary
    @embeddable_unit = EmbeddableUnit.find_by uuid:params[:embeddable_unit_uuid]
    authorize @embeddable_unit

    @response = Response.find params[:response_id]
  end

  def next_question
    @embeddable_unit = EmbeddableUnit.find_by uuid:params[:embeddable_unit_uuid]
    authorize @embeddable_unit

    @question = Question.find params[:question_id]
    next_question = @embeddable_unit.survey.next_question(@question)

    if next_question
      redirect_to new_question_response_path(next_question)
    else
      redirect_to embeddable_unit_thank_you_path(cookies[:euuid])
    end
  end

  def thank_you
    @embeddable_unit = EmbeddableUnit.find_by uuid:params[:embeddable_unit_uuid]
    authorize @embeddable_unit

    cookies.delete :euuid
  end
end