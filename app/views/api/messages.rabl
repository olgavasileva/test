object false
child @messages do
    attributes :id, :type, :read_at, :created_at
    attributes :question_id, :response_count, :comment_count, :share_count, :completed_at, if: :isQuestionUpdated?
    attribute :follower_id, if: :isUserFollowed?
    attribute :question_id, if: :isQuestionTargeted?
    attribute :body

end
node(:number_of_unread_messages) { @number }
