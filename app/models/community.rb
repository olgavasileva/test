class Community < ActiveRecord::Base
  belongs_to :user, class_name: "Respondent"
  has_many :members, class_name: 'CommunityMember', dependent: :destroy
  has_many :member_users, through: :members, source: :user
  has_many :communities_targets
  has_many :targets, through: :communities_targets

  validates :name, presence: true, uniqueness: { scope: :user_id }
  validates :user, presence: true
  validates :password, presence: true, if: :private?

  after_create :add_creator_as_member

  def public?
    !private?
  end

  private

  def add_creator_as_member
    member_users << user
  end
end
