class UserAvatar < ActiveRecord::Base
  has_one :user

  mount_uploader :avatar, UserAvatarUploader
end
