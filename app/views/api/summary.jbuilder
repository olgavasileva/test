json.summary do
  json.partial! 'question_summary', question:@question
  json.demographic_required @demographic_required unless @demographic_required.nil?
end