class FeedItem < ActiveRecord::Base
  belongs_to :user
  belongs_to :question

  # after_create :add_and_push_message


end
