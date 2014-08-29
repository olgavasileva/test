class TextChoiceResponse < Response
  belongs_to :choice, class_name: "TextChoice"

  validates :choice, presence: true
end