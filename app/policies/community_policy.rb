class CommunityPolicy < ApplicationPolicy
  def create?
    @user.present?
  end

  def update?
    @user == @record.user
  end

  def destroy?
    @user == @record.user
  end

  def invite?
    @user == @record.user
  end
end
