class GroupMemberPolicy < ApplicationPolicy
  def create?
    @user.present?
  end

  def destroy?
    @user == @record.group.user
  end
end
