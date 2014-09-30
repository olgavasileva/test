json.partial! 'question', question:@question
json.summary do
  json.partial! 'question_summary', question:@question
end
json.user_answered @user_answered