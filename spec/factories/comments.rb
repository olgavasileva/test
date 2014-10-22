FactoryGirl.define do
  factory :comment do
    user
    body
  end

  factory :text_question_comment, parent: :comment do
    association :commentable, factory: :text_question
  end

  factory :text_response_comment, parent: :comment do
    association :commentable, factory: :text_response
  end

  factory :comment_comment, parent: :comment do
    association :commentable, factory: :comment
  end
end
