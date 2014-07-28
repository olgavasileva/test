class BackgroundImage < ActiveRecord::Base
  acts_as_list

  mount_uploader :image, BackgroundImageUploader
end
