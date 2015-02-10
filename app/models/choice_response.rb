class ChoiceResponse < Response
  belongs_to :choice

  validates :choice, presence: true

  def description
    choice.id
  end

  def csv_data
    question.choices.order(:id).map{ |c| (c == choice) ? 1 : 0 }
  end
end