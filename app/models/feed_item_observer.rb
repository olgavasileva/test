class FeedItemObserver < ActiveRecord::Observer
  def after_update feed_item

    # When a user answers or skips a question, they are active,
    # so give them more feed items (in the background)
    if feed_item.skipped? || feed_item.answered?
      Resque.enqueue BuildRespondentFeed, feed_item.user_id, Figaro.env.QUESTIONS_TO_ADD_PER_RESPONSE
    end
  end
end