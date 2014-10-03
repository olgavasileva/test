class Group < ActiveRecord::Base
  belongs_to :user
  has_many :members, class_name:"GroupMember", dependent: :destroy
  has_many :member_users, class_name:"User", through: :members, source: :user

  validates :name, uniqueness: { scope: :user_id,
                                 message: "already used by this user" }
end
