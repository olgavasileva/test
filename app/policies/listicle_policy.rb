class ListiclePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def create?
    user_authorized?
  end

  def new?
    user_authorized?
  end

  def update?
    user_authorized?
  end

  def destroy?
    user_authorized?
  end

  def index?
    user_authorized?
  end

  def image_upload?
    user_authorized?
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

  def quantcast?
    true
  end

  private

  def user_authorized?
    user.publisher? || user.is_pro?
  end
end
