class UserAvatar < ActiveRecord::Base
  has_one :user

  mount_uploader :image, UserAvatarUploader

  validates :user, presence:true
end
