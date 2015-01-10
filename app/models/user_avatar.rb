class UserAvatar < ActiveRecord::Base
  has_one :user, class_name: "Respondent"

  mount_uploader :image, UserAvatarUploader

  validates :user, presence:true
end
