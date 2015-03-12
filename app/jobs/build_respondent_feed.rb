class BuildRespondentFeed
  @queue = :respondent

  def self.perform respondent_id
    respondent = Respondent.find_by id: respondent_id
    respondent.append_questions_to_feed! if respondent.present?
  end
end