json.profile do
  json.(@user, :username, :email)
  json.user_id @user.id
  json.member_since @user.created_at
  json.number_of_asked_questions @user.number_of_asked_questions
  json.number_of_answered_questions @user.number_of_answered_questions
  json.number_of_comments_left @user.number_of_comments_left
  json.number_of_followers @user.number_of_followers
end