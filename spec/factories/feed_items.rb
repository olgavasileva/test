FactoryGirl.define do
  factory :feed_item do
    user
    question
    hidden false
    why "public"

    trait :skipped do
      hidden true
      hidden_reason "skipped"
    end

    trait :answered do
      hidden true
      hidden_reason "answered"
    end

    trait :suspended do
      hidden true
      hidden_reason "suspended"
    end

    trait :deleted do
      hidden true
      hidden_reason "deleted"
    end
  end
end

