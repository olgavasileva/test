class SurveyPolicy < ApplicationPolicy
  def start?;             has_survey_questions?; end
  def question?;          has_survey_questions?; end
  def create_response?;   has_survey_questions?; end
  def thank_you?;         has_survey_questions?; end
  def quantcast?;         has_survey_questions?; end
  def question_viewed?;   has_survey_questions?; end

  def has_survey_questions?
    @record.try(:questions).present?
  end
end
