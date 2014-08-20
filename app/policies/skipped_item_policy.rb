class SkippedItemPolicy < ApplicationPolicy
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      user.skips
    end
  end

  def require_user? ; true; end
  def new?;     @user.present? && @record.user == @user; end
end