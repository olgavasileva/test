FactoryGirl.define do
  factory :comment do
    user
    question
    body
  end
end
