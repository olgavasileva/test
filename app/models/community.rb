class Community < ActiveRecord::Base
  belongs_to :user, class_name: "Respondent"
  has_many :members, class_name: 'CommunityMember', dependent: :destroy
  has_many :member_users, through: :members, source: :user
  has_many :communities_targets
  has_many :targets, through: :communities_targets

  scope :trending_for_user, ->(user, page = 1, per_page = 20) {
    questions = Question.arel_table
    communities = arel_table
    communities_targets = Arel::Table.new(:communities_targets)
    targets = Target.arel_table
    membered_communities = CommunityMember.where(user_id: user.id).pluck(:community_id)

    # there we have public not empty communities(that have some questions in it), and on what user
    # is not subcribed. we set the limit and offset for records that will be returned
    not_empty_communities = communities.
        join(communities_targets).on(communities[:id].eq(communities_targets[:community_id])).
        join(targets).on(targets[:id].eq(communities_targets[:target_id])).
        join(questions).on(targets[:id].eq(questions[:target_id])).
        group(questions[:target_id]).having(questions[:id].count.gt(0))

    trending = not_empty_communities.
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
