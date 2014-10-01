resp_ratios = @question.try :response_ratios
json.choices @question.choices do |c|
  json.id c.id
  json.response_ratio resp_ratios[c]
end
json.response_count @question.responses.count
json.view_count @question.view_count
json.comment_count @question.comment_count
json.share_count @question.share_count
json.skip_count @question.skip_count
json.published_at @question.created_at.to_i
json.sponsor nil
json.creator_id @question.user.id
json.creator_name @question.user.name
json.anonymous @anonymous
