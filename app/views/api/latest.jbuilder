json.cursor @cursor
json.questions @questions do |q|
  json.partial! 'question', question:q
end