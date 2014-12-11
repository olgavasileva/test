class UserObserver < ActiveRecord::Observer
  def after_create user
    # New users get all the public questions for their feed
    user.reset_feed!
  end
end