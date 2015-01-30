class ImageResponse < Response
  validates :image, presence:true

  mount_uploader :image, ResponseImageUploader

  def description
    "An image"
  end

  def csv_data
    [image.try(:url)]
  end
end