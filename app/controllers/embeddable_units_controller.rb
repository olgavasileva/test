class EmbeddableUnitsController < ApplicationController
  skip_before_action :authenticate_user!

  def start_survey
    eu = EmbeddableUnit.find_by uuid:params[:embeddable_unit_uuid]
    if eu && eu.survey && eu.survey.questions.present?
      cookies[:euuid] = {value: params[:embeddable_unit_uuid], expires: 1.day.from.now}
      redirect_to new_question_response_path(eu.survey.questions.first.id)
    end
  end

  def done
    @embeddable_unit = EmbeddableUnit.find_by uuid:params[:embeddable_unit_uuid]
    cookies.delete :euuid
  end
end