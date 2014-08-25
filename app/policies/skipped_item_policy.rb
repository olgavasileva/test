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

  def require_user? ; false; end
  def new?;     @user.present? ? @record.user == @user : @record.user.nil?; end
end