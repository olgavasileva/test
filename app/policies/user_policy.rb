class UserPolicy < ApplicationPolicy
  def require_user?;  true;   end
  def index?;         false;  end
  def show?
    @user == @record  # Users can only access their own record
  end
end