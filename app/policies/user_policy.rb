class UserPolicy < ApplicationPolicy
  def require_user?;  true;   end
  def index?;         false;  end
  def profile?;       true;   end
  def show?
    @user == @record  # Users can only access their own record
  end

  # Any logged in user can follow another user
  def follow?;        true;   end
  def first_question?;true;   end

  def dashboard?
    @user.has_role? :pro
  end

  def campaigns?
    @user.has_role? :pro
  end

  def segments?
    @user.has_role? :pro
  end

  def analytics?
    @user.has_role? :pro
  end

  def account?
    @user.has_role? :pro
  end
end