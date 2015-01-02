class TextResponseMatcher < ResponseMatcher
  validates :regex, presence: true  # not really a regex - just a string to match on for now

  protected
    # Must return an AREL object
    def matched_users_for_specific_response
      Respondent.joins(:responses).where("responses.question_id = ? AND responses.`text` like ?", question.id,"%#{regex}%")
    end
end