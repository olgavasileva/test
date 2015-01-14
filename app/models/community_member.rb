class CommunityMember < ActiveRecord::Base
  belongs_to :community
  belongs_to :user, class_name: "Respondent"

  validates :community_id, presence: true
  validates :user_id,
    presence: true,
    uniqueness: { scope: :community_id,
                  message: "is already part of this community" }
end
