class BuildRespondentFeed
  @queue = :respondent

  def self.perform respondent_id, num_questions_to_add = nil
    benchmark = Benchmark.measure do
      respondent = Respondent.find_by id: respondent_id
      if respondent.present? && respondent.needs_more_feed_items?
        respondent.append_questions_to_feed! num_questions_to_add
      end
    end

    Rails.logger.info "BuildRespondentFeed(#{respondent_id}, #{num_questions_to_add}): #{benchmark}"
  end
end