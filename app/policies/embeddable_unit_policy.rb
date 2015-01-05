class EmbeddableUnitPolicy < ApplicationPolicy
  def start_survey? ; true; end
  def summary?      ; true; end
  def next_question?; true; end
  def thank_you?    ; true; end
end