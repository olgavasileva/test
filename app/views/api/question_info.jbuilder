json.partial! 'question', question: @question
json.summary do
  json.partial! 'question_summary', question: @question
end
json.answers @answers if @user_answered
json.user_answered @user_answered