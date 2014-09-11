class TextChoice < Choice
  has_many :responses, class_name: "TextChoiceResponse", foreign_key: :choice_id, dependent: :destroy
  belongs_to :question, class_name:"TextChoiceQuestion", inverse_of: :choices
  validates :question, presence: true
end
