class GroupMember < ActiveRecord::Base
  belongs_to :group
  belongs_to :user, class_name: "Respondent"

  validates :group_id, presence: true
  validates :user_id,
    presence: true,
    uniqueness: { scope: :group_id, message: "is already part of this group" }
  validate :user_needs_to_follow_group_user

  private

  def user_needs_to_follow_group_user
    leaders = user.try(:leaders) || []

    unless leaders.include? group.user
      errors.add(:user_id, "needs to follow group user")
    end
  end
end
