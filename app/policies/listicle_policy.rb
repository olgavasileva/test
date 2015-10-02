class ListiclePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def create?
    user.publisher?
  end

  def new?
    user.publisher?
  end

  def update?
    user.publisher?
  end

  def destroy?
    user.publisher?
  end

  def index?
    user.publisher?
  end

  def image_upload?
    user.publisher?
  end

  def answer_question?
    true
  end

  def embed?
    true
  end

  def basic_form?
    user.publisher?
  end
end
