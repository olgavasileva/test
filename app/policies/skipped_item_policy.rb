class SkippedItemPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      user.skips
    end
  end

  def require_user? ; false; end
  def new?;     @user.present? ? @record.user == @user : @record.user.nil?; end
end