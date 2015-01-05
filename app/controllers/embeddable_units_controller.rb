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

  def thank_you
    @embeddable_unit = EmbeddableUnit.find_by uuid:params[:embeddable_unit_uuid]
    authorize @embeddable_unit

    cookies.delete :euuid
  end
end