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
            add_and_push_message follower, question
            target_count += 1
          end
        end
      else
        followers.each do |follower|
          if follower.leaders.include?(user) && follower.wants_question?(question)
            follower.feed_questions << question
            add_and_push_message follower, question
            target_count += 1
          end
        end
      end

      if all_groups
        user.group_members.each do |member|
          if member.wants_question? question
            member.feed_questions << question
            add_and_push_message member, question
            target_count += 1
          end
        end
      else
        groups.each do |group|
          if group.user == user
            group.member_users.each do |member_user|
              if member_user.wants_question? question
                member_user.feed_questions << question
                add_and_push_message member_user, question
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


    def add_and_push_message(targeted_user, question)


      message = QuestionTargeted.new

      message.user_id = targeted_user.user_id
      message.question_id = question.question_id

      user_name = question.anonymous? ? "Someone" : question.user.username
      message.body = "#{user_name} has a question for you"

      message.save

      targeted_user.instances.each do |instance|
        next unless instance.push_token.present?

        instance.push alert:'Hello iPhone!', badge:0, sound:true, other: {:type => message.type,
                                                                          :created_at => message.created_at,
                                                                          :read_at => message.read_at,
                                                                          :question_id => message.question_id,
                                                                          :body => message.body }
      end

      # if !QuestionTargeted.exists?(:user_id => self.user_id)
      #   message = QuestionTargeted.new
      # else
      #   message = QuestionTargeted.find_by_user_id(self.user_id)
      # end
      #
      #
      # message.user_id = self.question.user_id
      # message.question_id = self.question_id
      #
      # question = self.question
      # user_name = question.anonymous? ? "Someone" : question.user.username
      # message.body = "#{user_name} has a question for you"
      #
      # message.save
      #
      #
      #
      # self.user.instances.each do |instance|
      #   next unless instance.push_token.present?
      #
      #   APNS.send_notification(instance.push_token, :alert => 'Hello iPhone!', :badge => 0, :sound => 'default',
      #                          :other => {:type => message.type,
      #                                     :created_at => message.created_at,
      #                                     :read_at => message.read_at,
      #                                     :question_id => message.question_id,
      #                                     :body => message.body
      #                          })
      # end

    end
end
