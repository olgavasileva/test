class QuestionAction
  attr_accessor :response, :date

  def self.recent_actions user, since_time
    recent_responses = user.responses_to_questions.order("responses.created_at DESC").where("responses.created_at > ?", since_time)
    recent_skips = user.questions_skips.order("skipped_items.created_at DESC").where("skipped_items.created_at > ?", since_time)

    actions = []

    recent_responses.each do |response|
      actions << QuestionAction.new(response:response, date:response.created_at)
    end

    recent_skips.each do |skip_item|
      actions << QuestionAction.new(response:skip_item, date:skip_item.created_at)
    end
  end

  def response_id
    @response.id
  end

  def completed?
    @response.kind_of? Response
  end

  def respondent
    @response.try :user
  end

end