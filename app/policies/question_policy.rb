class QuestionPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user
        user.feed_questions.order("CASE WHEN questions.position IS NULL THEN 1 ELSE 0 END ASC").order("questions.position ASC").order("questions.kind ASC").order("questions.created_at DESC")
      else
        Question.active.order("CASE WHEN questions.position IS NULL THEN 1 ELSE 0 END ASC").order("questions.position ASC").order("RAND()")
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
  def results?;  @user.present? && @record.user == @user; end
  def update_targetable?; @user.present? && @record.user == @user; end

  def new_response_from_uuid?; true; end
end
