class Message < ActiveRecord::Base
  belongs_to :user
  before_create :defaults

  def defaults
    self.read_at = nil
  end

  def isQuestionUpdated?
    self.type == "QuestionUpdated"
  end

  def isUserFollowed?
    self.type == "UserFollowed"
  end

  def number_of_messages_unread
    return Message.responses.where("comment is not ?", nil).count
  end

  def body
    self.type
  end
end
