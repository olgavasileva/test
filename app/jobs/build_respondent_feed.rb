class BuildRespondentFeed
  @queue = :respondent

  def self.perform respondent_id
    benchmark = Benchmark.measure do
      respondent = Respondent.find_by id: respondent_id
      respondent.append_questions_to_feed! Figaro.env.MAX_QUESTIONS_FOR_NEW_RESPONDENT if respondent.present?
    end

    Rails.logger.info "BuildRespondentFeed #{Figaro.env.MAX_QUESTIONS_FOR_NEW_RESPONDENT}: #{benchmark}"
  end
end