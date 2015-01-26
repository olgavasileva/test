json.choices @question.choices do |c|
  json.id c.id
  top_count = c.try :top_count
  json.top_count top_count unless top_count.nil?
  json.response_ratio c.response_ratio
  json.user_answered @answers.include?(c.id) if @answers
end
json.response_count @question.responses.count
json.view_count [@question.view_count.to_i, @question.responses.count, @question.skip_count.to_i].max
json.comment_count @question.comment_count.to_i
json.share_count @question.share_count.to_i
json.skip_count @question.skip_count.to_i
json.start_count @question.start_count.to_i
json.published_at @question.created_at.to_i
json.sponsor nil
json.creator_id @question.user.id
json.creator_name @question.user.name
json.anonymous @question.anonymous
