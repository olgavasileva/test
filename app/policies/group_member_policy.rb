class GroupMemberPolicy < ApplicationPolicy
  def create?
    @user.present?
  end
end
