FactoryGirl.define do
  factory :question_target do
    respondent
    question
    target
  end
end