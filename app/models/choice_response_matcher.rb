class ChoiceResponseMatcher < ResponseMatcher
  belongs_to :choice

  validates :choice, presence: true, if: 'specific_responders?'

  protected
    # Must return an AREL object
    def matched_users_for_specific_response
      Respondent.joins(:responses).where(responses: {choice_id: choice.id})
    end
end