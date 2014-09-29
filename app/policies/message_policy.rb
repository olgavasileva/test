class MessagePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      user.messages.all
    end
  end
  def require_user? ; true; end
end