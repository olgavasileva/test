# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :message do
    user
  end

  factory :direct_question_message, parent: :message, class: "DirectQuestionMessage" do
    content "This is a direct question message."
  end

  factory :question_liked_message, parent: :message, class: "QuestionLikedMessage" do
    content "This is a question liked message."
  end

  factory :comment_liked_message, parent: :message, class: "CommentLikedMessage" do
    content "This is a comment liked message."
  end

end
