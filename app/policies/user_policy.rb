class UserPolicy < ApplicationPolicy
  def require_user?;  true;   end
  def index?;         false;  end
  def profile?;       true;   end
  def show?
    @user == @record  # Users can only access their own record
  end

  # Any logged in user can follow another user
  def follow?;        true;   end
end