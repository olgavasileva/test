class UserPolicy < ApplicationPolicy
  def require_user?;  true;   end
  def index?;         false;  end
  def profile?;       true;   end
  def show?;          true;   end

  # Any logged in user can follow another user
  def follow?;        true;   end
  def first_question?;true;   end

  def dashboard?
    @user == @record && @user.has_role?(:pro)
  end

  def recent_responses?
    @user == @record && @user.has_role?(:pro)
  end

  def recent_comments?
    @user == @record && @user.has_role?(:pro)
  end

  def campaigns?
    @user == @record && @user.has_role?(:pro)
  end

  def segments?
    @user == @record && @user.has_role?(:pro)
  end

  def analytics?
    @user == @record && @user.has_role?(:pro)
  end

  def account?
    @user == @record && @user.has_role?(:pro)
  end

end