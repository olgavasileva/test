class EmbeddableUnitPolicy < ApplicationPolicy
  def start_survey? ; true;      end
  def thank_you?    ; true;      end
  def done?         ; true;      end
end