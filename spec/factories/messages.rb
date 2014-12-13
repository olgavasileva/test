# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :message do
    user
  end

  factory :question_updated do
    user
    question factory: :text_question
  end

  factory :user_followed do
    user
    follower factory: :user
  end

  factory :question_targeted do
    user
  end

  factory :comment_liked_message do
    user
  end

  factory :custom do
    user
  end
end
