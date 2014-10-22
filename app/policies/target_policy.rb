class TargetPolicy < ApplicationPolicy
  def require_user? ; true; end
  def new?;           @record.user == @user; end
  def create?;        @record.user == @user; end
end