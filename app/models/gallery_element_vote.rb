class GalleryElementVote < ActiveRecord::Base
  belongs_to :gallery_element

  validates :user_id, presence: true

  scope :voted, ->(user_id) { where(["user_id = ? && updated_at >= ?", user_id, Time.now.midnight])}
end