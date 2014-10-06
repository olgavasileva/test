class Target < ActiveRecord::Base
  belongs_to :user
  has_many :questions
  has_and_belongs_to_many :followers, class_name: "User"
  has_and_belongs_to_many :groups

  validates :all_users, inclusion:{in:[true, false]}
  validates :all_followers, inclusion:{in:[true, false]}
  validates :all_groups, inclusion:{in:[true, false]}

  def follower_ids= follower_ids
    follower_ids.each do |id|
      self.followers << User.find(id)
    end if follower_ids.kind_of? Array
  end

  def group_ids= group_ids
    group_ids.each do |id|
      self.groups << Group.find(id)
    end if group_ids.kind_of? Array
  end

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
          if follower.leader == user && follower.wants_question?(question)
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
            group.members.each do |member|
              if member.wants_question? question
                member.feed_questions << question
                target_count += 1
              end
            end
          end
        end
      end
    end

    target_count
  end
end