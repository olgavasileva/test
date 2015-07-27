class ListicalPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def create?; true; end
  def new?; true; end
  def update?; true; end
  def destroy?; true; end
  def index?; true; end

end
