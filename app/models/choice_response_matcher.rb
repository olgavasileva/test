class ChoiceResponseMatcher < ResponseMatcher
  belongs_to :choice

  validates :choice, presence: true, if: 'specific_responders?'
end