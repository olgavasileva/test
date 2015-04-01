json.(question, :id, :title, :description, :response_count, :comment_count, :uuid, :anonymous)
if question.kind_of? YesNoQuestion
  json.type "TextChoiceQuestion"
else
  json.type question.type
end
json.creator_id question.user.id
json.creator_name question.user.username
if question.user.avatar
  json.creator_avatar_url question.user.avatar.image_url
else
  json.creator_avatar_url gravatar_url(question.user.email, default: :identicon)
end

json.survey_id question.survey_id
json.created_at question.created_at.to_i
json.tags question.tag_list

json.rotate question.rotate if question.kind_of? ChoiceQuestion

json.(question, :min_responses, :max_responses) if question.kind_of? MultipleChoiceQuestion

json.partial! 'background_image', image: question.background_image

json.(question, :text_type, :min_characters, :max_characters) if question.kind_of? TextQuestion

json.choices question.ordered_choices_for(current_user) do |choice|
  json.choice do
    json.(choice, :id, :title, :rotate)

    if choice.respond_to?(:background_image)
      json.partial! 'background_image', image: choice.background_image
    end

    json.(choice, :muex) if question.kind_of? MultipleChoiceQuestion
  end
end

json.category do
  json.((question.category || Category.find_by(name:"Random") || Category.first), :id, :name)
end

json.member_community_ids question.user.membership_communities.pluck(:id)
json.user_answered @answered_questions[question.id] if @answered_questions
