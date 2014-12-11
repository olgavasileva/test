class UserObserver < ActiveRecord::Observer
  def after_create user
    # New users get all the public questions for their feed
    Question.active.publik.order("created_at ASC").each do |q|
      FeedItem.create! user:user, question:q, published_at:q.created_at
    end
  end
end