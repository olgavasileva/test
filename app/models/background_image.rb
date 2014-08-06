class BackgroundImage < ActiveRecord::Base

  has_many :questions

  mount_uploader :image, BackgroundImageUploader

  def web_image_url
    image.web.url
  end

  def device_image_url
    image.device.url
  end

  def retina_device_image_url
    image.retina_device.url
  end
end
