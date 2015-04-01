json.survey do
  json.extract! @survey,
    :id,
    :name,
    :thank_you_markdown,
    :thank_you_html,
    :user_id

  json.questions do
    json.array! @survey.questions do |question|
      json.partial! 'question', question: question
    end
  end
end