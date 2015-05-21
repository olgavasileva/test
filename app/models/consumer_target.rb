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

  protected
    def apply! question
      question.update_attribute(:kind, all_users ? :public : :targeted)

      unless targeting_all_users?
        ActiveRecord::Base.transaction do
          target_respondents! question, all_followers? ? question.user.followers : followers
          target_respondents! question, all_groups? ? question.user.group_members : group_members
          target_respondents! question, all_communities? ? question.user.fellow_community_members : community_members
        end
      end
    end

    def targeting_all_users?
      !!all_users
    end

  private

    def set_defaults
      self.all_users = false if all_users.nil?
      self.all_followers = false if all_followers.nil?
      self.all_groups = false if all_groups.nil?
      self.all_communities = false if all_communities.nil?
    end

end