class ApplyTargetingToQuestion
  @queue = :question

  def self.perform question_id, target_id
    benchmark = Benchmark.measure do
      question = Question.find_by id: question_id
      target = Target.find_by id: target_id

      self.new.perform(question, target) if question
    end

    Rails.logger.info "ApplyTargetingToQuestion: #{benchmark}"
  end

  def perform question, target
    # Don't perform in the backgound since we're already in the background
    target.apply_to_question! question, background: false if target && question
  end

end
