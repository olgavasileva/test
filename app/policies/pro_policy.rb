class ProPolicy < ApplicationPolicy
  def initialize user, record
    raise Pundit::NotAuthorizedError, "Must be an enterprise user." unless user && user.has_role?(:pro)
    @user   = user
    @record = record
  end
end