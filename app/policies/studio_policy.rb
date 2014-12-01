class StudioPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      Studio.all
    end
  end

  def require_user? ; true;     end

  def show?  ;       true;     end
end