class TextQuestion < Question
  TEXT_TYPES ||= %w(email phone freeform)

  has_many :responses, class_name:"TextResponse", foreign_key: :question_id

  validates :text_type, inclusion: {in: TEXT_TYPES}
  validates :min_characters, presence:true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :max_characters, presence:true, numericality: { only_integer: true, greater_than_or_equal_to: :min_characters }
  validates :image, presence: true

  def device_image_url
    image.device.url
  end
end