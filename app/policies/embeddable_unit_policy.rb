class EmbeddableUnitPolicy < ApplicationPolicy
  def start_survey?; has_survey_questions?; end
  def survey_question?; has_survey_questions?; end
  def survey_response?; has_survey_questions?; end
  def thank_you?; has_survey_questions?; end

  def has_survey_questions?
    @record.try(:has_survey_questions?) || false
  end
end
