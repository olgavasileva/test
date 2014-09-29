class TargetPolicy < ApplicationPolicy
  def require_user? ; true; end
  def new?;           @record.question.user == @user; end
  def create?;        @record.question.user == @user; end
end