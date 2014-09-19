class Community < ActiveRecord::Base
  belongs_to :user
  has_many :members, class_name: 'CommunityMember', dependent: :destroy
  has_many :member_users, through: :members, source: :user

  validates :name, presence: true, uniqueness: { scope: :user_id }
  validates :user, presence: true
  validates :password, presence: true, if: :private?
end
