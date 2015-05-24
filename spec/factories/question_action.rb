FactoryGirl.define do
  factory :question_action_response do
    respondent
    question
  end

  factory :question_action_skip do
    respondent
    question
  end
end
