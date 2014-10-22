class EnterpriseTargetPolicy < ApplicationPolicy
  def require_user? ; true; end

  def owns_target?
    @record.user == @user
  end

  def new?      ; owns_target?  ; end
  def create?   ; owns_target?  ; end
end