class TextChoiceQuestion < ChoiceQuestion
  has_many :choices, foreign_key: :question_id, class_name: "TextChoice", dependent: :destroy
  has_many :responses, class_name:"TextChoiceResponse", foreign_key: :question_id
  belongs_to :background_image

  validates :background_image, presence: true

  accepts_nested_attributes_for :choices

  delegate :web_image_url, to: :background_image
  delegate :device_image_url, to: :background_image
  delegate :retina_device_image_url, to: :background_image
end