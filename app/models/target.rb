class Target < ActiveRecord::Base
  belongs_to :user, class_name: "Respondent"
  has_many :questions
  has_and_belongs_to_many :followers, class_name: "Respondent", association_foreign_key: :user_id
  has_and_belongs_to_many :groups
  has_and_belongs_to_many :communities

  validates :all_users, inclusion:{in:[true, false]}
  validates :all_followers, inclusion:{in:[true, false]}
  validates :all_groups, inclusion:{in:[true, false]}

  after_initialize :set_defaults

  def public?
    !!all_users
  end

  # Add the question to all of the appropriate users' feeds
  # Will not add a question to a user who already has this question in their feed
  def apply_to_question question
    ActiveRecord::Base.transaction do
      question.kind = all_users ? "public" : "targeted"
      question.activate!

      if all_followers
        user.followers.each { |follower| target_user follower, question }
      else
        followers.each do |follower|
          target_user follower, question if follower.leaders.include?(user)
        end
      end

      if all_groups
        user.group_members.each { |member| target_user member, question }
      else
        groups.each do |group|
          group.member_users.each { |member| target_user member, question } if group.user == user
        end
      end
    end
  end

  private

    def set_defaults
      self.all_users = false if all_users.nil?
      self.all_followers = false if all_followers.nil?
      self.all_groups = false if all_groups.nil?
    end

    def target_user user, question
      item = user.feed_items.find_by question_id:question

      if item
        item.update_attributes why: "targeted"
      else
        user.feed_items << FeedItem.new(question:question, relevance:1, why: "targeted")
      end

      question.add_and_push_message user
    end
end
