class QuestionTypePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      QuestionType.all
    end
  end

  def index?  ; true; end
end
