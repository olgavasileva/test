class ImageChoice < Choice
  belongs_to :question, class_name:"ImageChoiceQuestion", inverse_of: :choices
  belongs_to :background_image
  has_many :responses, class_name: "ImageChoiceResponse", foreign_key: :choice_id, dependent: :destroy

  default background_image_id: lambda{ |q| CannedChoiceImage.pluck(:id).sample }

  accepts_nested_attributes_for :background_image

  validates :background_image, presence: true

  delegate :web_image_url, to: :background_image
  delegate :device_image_url, to: :background_image
  delegate :retina_device_image_url, to: :background_image
end
