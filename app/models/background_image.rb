class BackgroundImage < ActiveRecord::Base

  has_many :questions
  has_many :choices
  has_many :ad_unit_infos, class_name: "BackgroundImagesAdUnit"

  def ad_unit_info ad_unit_name
    ad_unit_infos.joins(:ad_unit).find_by(ad_unit: {name: ad_unit_name})
  end

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
