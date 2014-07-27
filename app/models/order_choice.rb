class OrderChoice < Choice
  has_and_belongs_to_many :responses, join_table: :order_choices_response
  mount_uploader :image, OrderChoiceImageUploader

  def device_image_url
    image.device.url
  end
end