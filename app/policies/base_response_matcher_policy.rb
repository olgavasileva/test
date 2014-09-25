class BaseResponseMatcherPolicy < ApplicationPolicy
  def owns_matcher?
    @user == @record.segment.user
  end

  def new?;     owns_matcher?; end
  def create?;  owns_matcher?; end
  def destroy?; owns_matcher?; end
end