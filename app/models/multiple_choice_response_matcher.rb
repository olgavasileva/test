class MultipleChoiceResponseMatcher < ResponseMatcher
  belongs_to :choice

  validates :choice, presence: true, if: 'specific_responders?'

  protected
    # Must return an AREL object
    def matched_users_for_specific_response
      User.joins(multiple_choice_responses: :choices_responses).where(choices_responses: {multiple_choice_id: choice.id})
    end
end