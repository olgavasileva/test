class ConsumerTarget < Target
  belongs_to :user, class_name: "Respondent"
  has_and_belongs_to_many :followers, foreign_key: :target_id, class_name: "Respondent", association_foreign_key: :user_id
  has_and_belongs_to_many :groups, foreign_key: :target_id
  has_many :group_members, through: :groups, source: :members

  has_and_belongs_to_many :communities, foreign_key: :target_id
  has_many :community_members, through: :communities, source: :member_users

  validates :all_users, inclusion:{in:[true, false]}
  validates :all_followers, inclusion:{in:[true, false]}
  validates :all_groups, inclusion:{in:[true, false]}
  validates :all_communities, inclusion:{in:[true,false]}

  after_initialize :set_defaults

  def public?
    !!all_users
  end

  def apply_to_question question
    question.update_attribute(:kind, all_users ? "public" : "targeted")

    if all_followers
      # Target each follower
    end

    if all_groups
      # Target each group member
    end

    if all_communities
      # Target each community member

    end
  end

  private

  def set_defaults
    self.all_users = false if all_users.nil?
    self.all_followers = false if all_followers.nil?
    self.all_groups = false if all_groups.nil?
    self.all_communities = false if all_communities.nil?
  end
end