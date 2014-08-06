class TextQuestion < Question
  TEXT_TYPES ||= %w(email phone freeform)

  has_many :responses, class_name:"TextResponse", foreign_key: :question_id
  belongs_to :background_image

  validates :text_type, inclusion: {in: TEXT_TYPES}
  validates :min_characters, presence:true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :max_characters, presence:true, numericality: { only_integer: true, greater_than_or_equal_to: :min_characters }
  validates :background_image, presence: true

  delegate :web_image_url, to: :background_image
  delegate :device_image_url, to: :background_image
  delegate :retina_device_image_url, to: :background_image
end