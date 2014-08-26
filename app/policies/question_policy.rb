class QuestionPolicy < ApplicationPolicy
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if user
        user.feed_questions.order("questions.kind ASC").order("questions.created_at DESC")
      else
        Question.active.order("RAND()")
      end
    end
  end

  def require_user? ; false; end
  def index?  ; true; end
  def summary? ; true; end
  def new?;     @user.present? && @record.user == @user; end
  def create?;  @user.present? && @record.user == @user; end
  def edit?;    @user.present? && @record.user == @user; end
  def update?;  @user.present? && @record.user == @user; end
  def target?;  @user.present? && @record.user == @user; end
  def enable?;  @user.present? && @record.user == @user; end
end