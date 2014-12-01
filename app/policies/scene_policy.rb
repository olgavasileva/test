class ScenePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      @user.scenes
    end
  end

  def require_user? ; true;     end

  def index?  ;       true;     end
  def create? ;       true;     end
end