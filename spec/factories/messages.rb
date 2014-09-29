# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :message do
    user
  end

  factory :question_updated, parent: :message, class: "QuestionUpdated" do
    question_id 1
    response_count 3
    comment_count 2
    share_count 2
  end

  factory :user_followed, parent: :message, class: "UserFollowed" do
    follower_id 2
  end

  factory :custom, parent: :message, class: "Custom" do

  end

end
