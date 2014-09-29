class SkippedItem < ActiveRecord::Base
  belongs_to :user
  belongs_to :question

  validates :user, presence: true
  validates :question, presence: true, uniqueness: { scope: :user_id }

  before_save :remove_from_feed

  private
    def remove_from_feed
      user.feed_items.where(question_id:question).destroy_all if user
    end
end
