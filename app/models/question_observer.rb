class QuestionObserver < ActiveRecord::Observer
  def before_destroy question
    FeedItem.question_deleted! question
  end
end
