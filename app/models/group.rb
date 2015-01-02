class Group < ActiveRecord::Base
  belongs_to :user, class_name: "Respondent"
  has_many :members, class_name: "GroupMember", dependent: :destroy
  has_many :member_users, through: :members, source: :user
  has_many :groups_targets
  has_many :targets, through: :groups_targets

  validates :name, uniqueness: { scope: :user_id,
                                 message: "already used by this user" }
end
