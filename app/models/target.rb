class Target < ActiveRecord::Base
  belongs_to :user
  has_many :questions
  has_and_belongs_to_many :followers, class_name: "User"
  has_and_belongs_to_many :groups

  validates :all_users, inclusion:{in:[true, false]}
  validates :all_followers, inclusion:{in:[true, false]}
  validates :all_groups, inclusion:{in:[true, false]}

  after_initialize :set_defaults

  def public?
    !!all_users
  end

  # Add the question to all of the appropriate users' feed
  # Will not add a question to a user who already has this question in their feed or skip list
  def apply_to_question question
    target_count = 0

    ActiveRecord::Base.transaction do
      question.kind = all_users ? "public" : "targeted"
      question.activate!

      if all_followers
        user.followers.each do |follower|
          if follower.wants_question? question
            follower.feed_questions << question
            target_count += 1
          end
        end
      else
        followers.each do |follower|
          if follower.leaders.include?(user) && follower.wants_question?(question)
            follower.feed_questions << question
            target_count += 1
          end
        end
      end

      if all_groups
        user.group_members.each do |member|
          if member.wants_question? question
            member.feed_questions << question
            target_count += 1
          end
        end
      else
        groups.each do |group|
          if group.user == user
            group.member_users.each do |member_user|
              if member_user.wants_question? question
                member_user.feed_questions << question
                target_count += 1
              end
            end
          end
        end
      end
    end

    target_count
  end

  private

    def set_defaults
      self.all_users = false if all_users.nil?
      self.all_followers = false if all_followers.nil?
      self.all_groups = false if all_groups.nil?
    end
end
