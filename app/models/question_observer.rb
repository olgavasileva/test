class QuestionObserver < ActiveRecord::Observer
  def before_destroy question
    FeedItem.question_deleted! question
  end

  def after_save question
    Resque.enqueue AddQuestionToAllFeeds, question.id if question.public? && question.state_was != 'active' && question.state == 'active'
  end
end