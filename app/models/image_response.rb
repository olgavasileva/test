class ImageResponse < Response
  validates :image, presence:true

  mount_uploader :image, ImageUploader
end