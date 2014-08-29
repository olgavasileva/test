class MultipleChoiceResponse < Response
  has_many :choices_responses
  has_many :choices, through: :choices_responses

  def text
    choices.map(&:text).join(', ')
  end
end
