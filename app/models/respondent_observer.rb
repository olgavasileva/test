class RespondentObserver < ActiveRecord::Observer
  def after_create respondent
    # New users get all the public questions for their feed
    respondent.reset_feed!
  end
end