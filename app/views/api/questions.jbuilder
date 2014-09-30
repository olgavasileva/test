json.array! @questions do |q|
  json.question do
    json.partial! 'question', question:q
  end
end