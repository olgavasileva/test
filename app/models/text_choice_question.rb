class TextChoiceQuestion < ChoiceQuestion
  has_many :choices, class_name: "TextChoice", foreign_key: :question_id, dependent: :destroy, inverse_of: :question
  has_many :responses, class_name:"TextChoiceResponse", foreign_key: :question_id

  default background_image_id: lambda{ |q| CannedQuestionImage.pluck(:id).sample }

  validates :background_image, presence: true

  accepts_nested_attributes_for :choices

  delegate :web_image_url, to: :background_image
  delegate :device_image_url, to: :background_image
  delegate :retina_device_image_url, to: :background_image
end
