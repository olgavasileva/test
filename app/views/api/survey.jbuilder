json.survey do
  json.extract! @survey, :id, :name

  json.questions do
    json.array! @survey.questions do |question|
      json.partial! 'question', question: question
    end
  end

  json.embeddable_units do
    json.array! @survey.embeddable_units do |unit|
      json.partial! 'embeddable_unit', unit: unit
    end
  end
end
