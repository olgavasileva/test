json.choices @question.choices do |c|
  json.id c.id
  top_count = c.try :top_count
  json.top_count top_count unless top_count.nil?
  # json.response_ratio c.response_ratio
  json.user_answered @answers.include?(c.id) if @answers
  json.response_ratio @question.kind_of?(OrderQuestion) ? c.weighted_response_count / question.weighted_total_responses.to_f : c.responses.count.to_f / question.choice_count
end
json.response_count @question.response_count
json.view_count [@question.view_count.to_i, @question.response_count, @question.skip_count.to_i].max
json.comment_count @question.comment_count.to_i
json.share_count @question.share_count.to_i
json.skip_count @question.skip_count.to_i
json.start_count 0
json.published_at @question.created_at.to_i
json.sponsor nil

if !@question.anonymous? || (current_user && current_user.id == @question.user.id)
  json.creator_id @question.user.id
  json.creator_name @question.user.name
else
  json.creator_name 'anonymous'
end

json.anonymous @question.anonymous
