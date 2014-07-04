class CategoryPolicy < ApplicationPolicy
  def require_user? ; false; end
  def index?  ; true;                                    end
end