class ChoiceResponse < Response
  belongs_to :choice

  validates :choice, presence: true

  def description
    choice.id
  end

  def csv_data
    ["Choice id #{choice.id}"]
  end
end