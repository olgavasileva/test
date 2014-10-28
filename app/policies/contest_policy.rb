class ContestPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      Category.order(:name)
    end
  end

  def require_user? ; false;            end
  def sign_up?  ;     true;             end
  def new_user? ;     true;             end
  def question? ;     true;             end
  def vote? ;         true;             end
  def save_vote? ;    true;             end
  def scores? ;       true;             end
end