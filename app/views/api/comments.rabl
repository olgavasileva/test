collection @responses, object_root: false

attributes :id, :user_id, :comment

node(:created_at) { |r| r.created_at.to_i }
node(:email) { |r| r.user.email }
node(:ask_count) { |r| r.user.questions.count }
node(:response_count) { |r| r.user.responses.count }
node(:comment_count) { |r| r.user.responses.with_comment.count }
