class TextChoiceQuestion < ChoiceQuestion
  has_many :choices, foreign_key: :question_id, class_name: "TextChoice", dependent: :destroy
  has_many :responses, class_name:"TextChoiceResponse", foreign_key: :question_id

  validates :image, presence: true
end