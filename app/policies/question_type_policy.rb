class QuestionTypePolicy < ApplicationPolicy
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      QuestionType.all
    end
  end

  def index?  ; true; end
end
