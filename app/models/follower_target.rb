# Obsolete
class FollowerTarget < ActiveRecord::Base
  belongs_to :question
  belongs_to :follower, class_name: 'User'

  validates :question, presence: true
  validates :follower, presence: true

  validate :follower_follows_question_user

  private

  def follower_follows_question_user
    unless question.user.followers.include? follower
      errors.add(:follower_id, "must follow question user")
    end
  end
end
