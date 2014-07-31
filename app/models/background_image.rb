class BackgroundImage < ActiveRecord::Base
  acts_as_list

  mount_uploader :image, BackgroundImageUploader

  def device_image_url
    image.device.url
  end
end
