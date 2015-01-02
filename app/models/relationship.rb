class Relationship < ActiveRecord::Base
	belongs_to :follower, class_name: "Respondent"
	belongs_to :leader, class_name: "Respondent"

	validates :follower, presence: true
	validates :leader, presence: true, uniqueness: { scope: :follower_id }
  validate :not_following_self

  # Leader's groups that follower is member of.
  def groups
    follower.membership_groups.where(user_id: leader.id)
  end

  private

  def not_following_self
    if leader_id == follower_id
      errors.add(:leader_id, "can't follow themselves")
    end
  end
end
