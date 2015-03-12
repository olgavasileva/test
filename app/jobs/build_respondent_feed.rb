class BuildRespondentFeed
  @queue = :respondent

  def self.perform respondent_id
    respondent = Respondent.find_by id: respondent_id
    respondent.append_questions_to_feed! Figaro.env['MAX_QUESTIONS_FOR_NEW_RESPONDENT'] if respondent.present?
  end
end