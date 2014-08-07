module QuestionHelper
  def canned_images
    @canned_images ||= CannedImage.order(:position)
  end

  def canned_image_ids
     canned_images.pluck(:id)
  end

  def canned_image_web_urls
    canned_images.map{|i| i.web_image_url}
  end
end