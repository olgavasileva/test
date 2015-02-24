class Target < ActiveRecord::Base
  belongs_to :user, class_name: "Respondent"
  has_many :questions
  has_and_belongs_to_many :followers, class_name: "Respondent", association_foreign_key: :user_id
  has_and_belongs_to_many :groups
  has_many :group_members, through: :groups, source: :members

  has_and_belongs_to_many :communities
  has_many :community_members, through: :communities, source: :members

  validates :all_users, inclusion:{in:[true, false]}
  validates :all_followers, inclusion:{in:[true, false]}
  validates :all_groups, inclusion:{in:[true, false]}

  after_initialize :set_defaults

  def public?
    !!all_users
  end

  # Sends the question to be added to feeds in the background while updating the
  # `question#kind` attribute based on the targets attributes.
  #
  def apply_to_question question
    question.update_attribute(:kind, all_users ? "public" : "targeted")
    Resque.enqueue(AddQuestionToAllFeeds, question.id)
  end

  private

  def set_defaults
    self.all_users = false if all_users.nil?
    self.all_followers = false if all_followers.nil?
    self.all_groups = false if all_groups.nil?
  end
end
