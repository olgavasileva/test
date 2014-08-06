class BackgroundImage < ActiveRecord::Base

  has_many :questions

  mount_uploader :image, BackgroundImageUploader

  def standard_image_url
    image.web.url
  end

  def retina_image_url
    image.retina_web.url
  end
end
