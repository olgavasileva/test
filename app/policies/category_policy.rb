class CategoryPolicy < ApplicationPolicy
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      Category.order(:name)
    end
  end

  def require_user? ; false;      end
  def index?  ;     true;       end
end