class CategoryPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      Category.order(:name)
    end
  end

  def require_user? ; false;      end
  def index?  ;     true;       end
end