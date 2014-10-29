class QuestionTypePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      QuestionType.all
    end
  end

  def index?
    !@user.anonymous?
  end
end
