object false
child @messages do
    attributes :type, :read_at, :created_at
    attributes :question_id, :response_count, :comment_count, :share_count, :completed_at, if: :isQuestionUpdated?
    attribute :follower_id, if: :isUserFollowed?
end
node(:number_of_unread_messages) { @number }
