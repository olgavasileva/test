json.survey do
  json.extract! @survey,
    :id,
    :name,
    :redirect,
    :redirect_url,
    :redirect_timeout,
    :thank_you_markdown,
    :thank_you_html,
    :thank_you_default,
    :user_id,
    :uuid

  json.questions do
    json.array! @survey.questions do |question|
      json.partial! 'question', question: question
    end
  end
end
