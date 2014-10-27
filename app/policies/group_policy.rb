class GroupPolicy < ApplicationPolicy
  def create?
    @user.present?
  end

  def update?
    @user == @record.user
  end

  def destroy?
    @user == @record.user
  end
end
