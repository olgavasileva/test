class Group < ActiveRecord::Base
  belongs_to :user
  has_many :members, class_name:"GroupMember", dependent: :destroy
  has_many :member_users, class_name:"User", through: :members, source: :user
end
