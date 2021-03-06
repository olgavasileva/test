class Message < ActiveRecord::Base
  belongs_to :user, class_name: "Respondent"

  default read_at: nil
  default share_count: 0

  scope :newest_first, -> { order "created_at DESC, id DESC" }

  def isQuestionUpdated?
    self.type == "QuestionUpdated"
  end

  def isUserFollowed?
    self.type == "UserFollowed"
  end

  def isQuestionTargeted?
    self.type == "QuestionTargeted"
  end

  def number_of_messages_unread
    return Message.responses.where("comment is not ?", nil).count
  end

  def read?
    read_at.present?
  end


end
