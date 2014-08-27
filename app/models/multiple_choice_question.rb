class MultipleChoiceQuestion < ChoiceQuestion
  has_many :choices, class_name:"MultipleChoice", foreign_key: :question_id, dependent: :destroy, inverse_of: :question
  has_many :responses, class_name:"MultipleChoiceResponse", foreign_key: :question_id

  default min_responses: 1

  validates :min_responses, presence:true, numericality: { only_integer: true, greater_than: 0 }
  validates :max_responses, numericality: { only_integer: true, greater_than_or_equal_to: :min_responses, allow_nil: true }

  accepts_nested_attributes_for :choices, allow_destroy:true
end