class GroupPolicy < ApplicationPolicy
  def create?
    @user.present?
  end
end
