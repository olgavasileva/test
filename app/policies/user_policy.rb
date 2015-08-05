class UserPolicy < ApplicationPolicy
  def require_user?;  true;   end
  def index?;         false;  end
  def profile?;       true;   end
  def show?;          !@user.anonymous?;   end

  # Any logged in user can follow another user
  def follow?;        true;   end
  alias :unfollow? :follow?

  def is_owner?
    @user == @record
  end

  def is_pro?
    @user.has_role?(:pro)
  end

  def publisher?
    @user.publisher?
  end


  def dashboard?
    is_owner? && (is_pro? || publisher?)
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

  def question_analytics?
    is_owner? && is_pro?
  end

  def demographics?
    is_owner? && is_pro?
  end

  def question_search?
    is_owner? && is_pro?
  end

  def account?
    is_owner? && is_pro?
  end

  def update?
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

  def publisher_question_packs?
    is_owner? && publisher?
  end

  def publisher_dashboard?
    is_owner? && publisher?
  end

  def avatar?
    true
  end

  def new_question?
    is_owner? && (is_pro? || publisher?)
  end

  def new_listical?
    is_owner? && (is_pro? || publisher?)
  end
end
