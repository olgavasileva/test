json.(question, :id, :type, :title, :description, :response_count, :comment_count, :uuid)
json.creator_id question.user.id
json.creator_name question.user.name

json.rotate question.rotate if question.kind_of? ChoiceQuestion

json.(question, :min_responses, :max_responses) if question.kind_of? MultipleChoiceQuestion

json.image_url question.device_image_url if question.kind_of?(TextQuestion) || question.kind_of?(TextChoiceQuestion)

json.(question, :text_type, :min_characters, :max_characters) if question.kind_of? TextQuestion

json.choices question.choices do |choice|
  json.choice do
    json.(choice, :id, :title, :rotate)
    json.image_url choice.device_image_url if question.kind_of?(OrderQuestion) || question.kind_of?(ImageChoiceQuestion) || question.kind_of?(MultipleChoiceQuestion)
    json.(choice, :muex) if question.kind_of? MultipleChoiceQuestion
  end
end

json.category do
  json.(question.category, :id, :name)
end
