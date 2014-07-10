FactoryGirl.define do
  factory :micropost do
  	content "Lorem ipsum"
  	user
  end

  factory :pack do
    title "Lorem ipsum"
    user
  end

  factory :comment do
    content "Lorem ipsum"
    user
    question
  end

  factory :sharing do
    question
  end
end