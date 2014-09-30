json.messages @messages do |message|
  json.message do
    json.(message, :id, :type, :read_at, :created_at, :body)
    json.(message, :question_id, :response_count, :comment_count, :share_count, :completed_at) if message.isQuestionUpdated?
    json.(message, :follower_id) if message.isUserFollowed?
    json.(message, :question_id) if message.isQuestionTargeted?
  end
end
json.number_of_unread_messages @number
