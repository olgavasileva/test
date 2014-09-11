collection @messages, object_root: :message
attributes :type, :read_at, :created_at
attributes :question_id, :response_count, :comment_count, :share_count, :completed_at, if: :isQuestionUpdated?
attribute :follower_id, if: :isUserFollowed?
