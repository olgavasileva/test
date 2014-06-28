class MultipleChoiceResponse < Response
  has_many :choices_responses
  has_many :choices, through: :choices_responses
end