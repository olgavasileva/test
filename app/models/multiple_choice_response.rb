class MultipleChoiceResponse < Response
  has_many :choices_responses
  has_many :choices, through: :choices_responses

  def text
    choices.map(&:title).join(', ')
  end

  def description
    text
  end

  def choice_ids
    choices.map(&:id).join(', ')
  end

  def csv_data
    ["Choices #{choice_ids}: #{text}"]
  end
end
