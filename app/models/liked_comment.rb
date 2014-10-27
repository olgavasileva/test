class LikedComment < ActiveRecord::Base
  belongs_to :user
  belongs_to :comment

  validates :user, presence: true
  validates :comment, presence: true, uniqueness: { scope: :user_id }
end
