class SkippedItem < ActiveRecord::Base
  belongs_to :user
  belongs_to :question

  before_save :remove_from_feed

  private
    def remove_from_feed
      user.feed_items.where(question_id:question).destroy_all if user
    end
end
