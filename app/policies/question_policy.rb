class QuestionPolicy < ApplicationPolicy
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if user
        user.unanswered_questions.order("created_at DESC")
      else
        Question.order("created_at DESC")
      end
    end
  end

  def require_user? ; false; end
  def index?  ; true; end
end