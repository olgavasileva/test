class Relationship < ActiveRecord::Base
	belongs_to :follower, class_name: "User"
	belongs_to :leader, class_name: "User"

	validates :follower, presence: true
	validates :leader, presence: true

  # Leader's groups that follower is member of.
  def groups
    follower.membership_groups.where(user_id: leader.id)
  end
end
