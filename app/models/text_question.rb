class TextQuestion < Question
  TEXT_TYPES ||= %w(email phone freeform)

  has_many :responses, class_name:"TextResponse", foreign_key: :question_id
  has_many :response_matchers, class_name:"TextResponseMatcher", foreign_key: :question_id, dependent: :destroy

  default text_type: "freeform"
  default min_characters: 1
  default max_characters: 2000

  validates :text_type, inclusion: {in: TEXT_TYPES}
  validates :min_characters, presence:true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :max_characters, presence:true, numericality: { only_integer: true, greater_than_or_equal_to: :min_characters }
  validates :background_image, presence: true

  default background_image_id: lambda{ |q| CannedQuestionImage.pluck(:id).sample }
end
