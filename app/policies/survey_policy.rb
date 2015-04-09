class SurveyPolicy < ApplicationPolicy
  def start?;             true; end
  def question?;          true; end
  def create_response?;   true; end
  def skip?;              true; end
  def thank_you?;         true; end
  def quantcast?;         true; end
end
