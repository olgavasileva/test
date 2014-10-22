# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :message do
    user
  end

  factory :question_updated, parent: :message, class: "QuestionUpdated" do
    question factory: :text_question
  end

  factory :user_followed, parent: :message, class: "UserFollowed" do
    follower factory: :user
  end

  factory :custom, parent: :message, class: "Custom" do

  end

end
