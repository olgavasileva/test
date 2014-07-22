class TextChoice < Choice
  has_many :responses, class_name: "TextChoiceResponse", foreign_key: :choice_id, dependent: :destroy
end
