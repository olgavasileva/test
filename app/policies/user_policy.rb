class UserPolicy < ApplicationPolicy
  def require_user?;  true;   end
  def index?;         false;  end
  def profile?;       true;   end
  def show?;          true;   end

  # Any logged in user can follow another user
  def follow?;        true;   end
  def first_question?;true;   end
  alias :unfollow? :follow?

  def is_owner?
    @user == @record
  end

  def is_pro?
    @user.has_role?(:pro)
  end


  def dashboard?
    is_owner? && is_pro?
  end

  def recent_responses?
    is_owner? && is_pro?
  end

  def recent_comments?
    is_owner? && is_pro?
  end

  def campaigns?
    is_owner? && is_pro?
  end

  def new_campaign?
    is_owner? && is_pro?
  end

  def create_campaign?
    is_owner? && is_pro?
  end

  def segments?
    is_owner? && is_pro?
  end

  def analytics?
    is_owner? && is_pro?
  end

  def account?
    is_owner? && is_pro?
  end

  def show_notifications?
    is_owner?
  end

  def show_join_communities?
    is_owner?
  end

  def show_create_community?
    is_owner?
  end
end
