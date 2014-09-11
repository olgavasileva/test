object @user => :profile
attributes :username, :email
attributes :id => :user_id, :created_at => :member_since
node :number_of_asked_questions do |u|
  u.number_of_asked_questions
end
node :number_of_answered_questions do |u|
  u.number_of_answered_questions
end
node :number_of_comments_left do |u|
  u.number_of_comments_left
end

