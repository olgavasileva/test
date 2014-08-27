class Target
  include ActiveModel::Model

  attr_accessor(
    :question,
    :question_id,

    :all_users,

    :all_followers,
    :all_groups,

    :follower_ids,
    :group_ids
  )

  validates :question_id, presence:true
  validates :all_users, inclusion:{in:[true, false]}
  validates :all_followers, inclusion:{in:[true, false]}
  validates :all_groups, inclusion:{in:[true, false]}

  def question_id= question_id
    @question_id = question_id
    @question = Question.find question_id
  end

  def question= question
    @question_id = question.id
    @question = question
  end

  def public?
    !!@all_users
  end


  # Add the question to all of the appropriate users' feed
  # Will not add a question to a user who already has this question in their feed or skip list
  def apply_to_user user
    target_count = 0

    ActiveRecord::Base.transaction do
      @question.kind = @all_users ? "public" : "targeted"
      @question.activate!

      if @all_followers
        user.followers.each do |follower|
          if follower.wants_question? @question
            follower.feed_questions << @question
            target_count += 1
          end
        end
      elsif @follower_ids
        @follower_ids.each do |follower_id|
          follower = user.followers.where(id:follower_id).first
          if follower && follower.wants_question?(@question)
            follower.feed_questions << @question
            target_count += 1
          end
        end
      end

      if @all_groups
        user.group_members.each do |member|
          if member.wants_question? @question
            member.feed_questions << @question
            target_count += 1
          end
        end
      elsif @group_ids
        @group_ids.each do |group_id|
          group = user.groups.where(id:group_id).first
          group.members.each do |member|
            if member.wants_question? @question
              member.feed_questions << @question
              target_count += 1
            end
          end if @group
        end
      end
    end

    target_count
  end
end