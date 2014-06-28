class ChoiceResponse < Response
  belongs_to :choice

  validates :choice, presence: true
end