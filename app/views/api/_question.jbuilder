json.(question, :id, :title, :description, :response_count, :comment_count, :uuid, :anonymous)
if question.kind_of? YesNoQuestion
  json.type "TextChoiceQuestion"
else
  json.type question.type
end
json.creator_id question.user.id
json.creator_name question.user.username
json.created_at question.created_at.to_i

json.rotate question.rotate if question.kind_of? ChoiceQuestion

json.(question, :min_responses, :max_responses) if question.kind_of? MultipleChoiceQuestion

json.image_url question.device_image_url

json.(question, :text_type, :min_characters, :max_characters) if question.kind_of? TextQuestion

json.choices question.ordered_choices_for(current_user) do |choice|
  json.choice do
    json.(choice, :id, :title, :rotate)
    json.image_url choice.device_image_url if question.kind_of?(OrderQuestion) || question.kind_of?(ImageChoiceQuestion) || question.kind_of?(MultipleChoiceQuestion)
    json.(choice, :muex) if question.kind_of? MultipleChoiceQuestion
  end
end

json.tags question.tag_list.map { |t| "##{t}" }

json.category do
  json.(question.category, :id, :name)
end

json.member_community_ids question.user.membership_communities.pluck(:id)
json.user_answered @answered_questions[question.id] if @answered_questions
