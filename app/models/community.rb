class Community < ActiveRecord::Base
  belongs_to :user, class_name: "Respondent"
  has_many :members, class_name: 'CommunityMember', dependent: :destroy
  has_many :member_users, through: :members, source: :user
  has_many :communities_targets
  has_many :targets, through: :communities_targets

  scope :trending_for_user, ->(user, page, per_page) {
    questions = Question.arel_table
    communities = arel_table
    community_member = CommunityMember.arel_table
    users = Respondent.arel_table
    membered_communities = CommunityMember.where(user_id: user.id).pluck(:community_id)
    
    # there we have public not empty communities(that have some questions in it), and on what user
    # is not subcribed. we set the limit and offset for records that will be returned 
    trending = communities.
        join(community_member).on(communities[:id].eq(community_member[:community_id])).
        join(users).on(users[:id].eq(community_member[:user_id])).
        join(questions).on(communities[:user_id].eq(questions[:user_id])).
        group(questions[:user_id]).having(questions[:id].count.gt(0)).
        where(communities[:id].not_in(membered_communities).and(communities[:private].eq(false))).
        take(per_page).skip((page - 1) * per_page).project(communities[Arel.star])
    find_by_sql(trending)
  }

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
