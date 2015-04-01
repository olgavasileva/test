json.survey do
  json.extract! @survey, :id, :name, :user_id

  json.questions do
    json.array! @survey.questions do |question|
      json.partial! 'question', question: question
    end
  end
end
