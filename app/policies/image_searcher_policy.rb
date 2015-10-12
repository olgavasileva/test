class ImageSearcherPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def create?
    user.is_pro? || user.publisher?
  end
end
