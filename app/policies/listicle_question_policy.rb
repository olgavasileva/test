class ListicleQuestionPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def edit?
    is_authorized?
  end

  def update?
    is_authorized?
  end

  private

  def is_author?
    record.listicle.user == user
  end

  def is_authorized?
    is_author? && user.is_pro? || user.publisher?
  end
end
