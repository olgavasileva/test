class GalleryElementVote < ActiveRecord::Base
  belongs_to :gallery_element
  belongs_to :user, class_name: "Respondent"

  validates :user_id, presence: true

  scope :voted, ->(user_id) { where(["user_id = ? && updated_at >= ?", user_id, Time.now.midnight])}
end