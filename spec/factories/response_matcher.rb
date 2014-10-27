FactoryGirl.define do
  factory :response_matcher do
    inclusion "skip"

    trait :skip do
      inclusion "skip"
    end
    trait :respond do
      inclusion "respond"
    end
    trait :specific do
      inclusion "specific"
    end
  end

  factory :text_response_matcher, parent: :response_matcher, class: "TextResponseMatcher" do
    regex "SOMETHING"
  end

  factory :choice_response_matcher, parent: :response_matcher, class: "ChoiceResponseMatcher" do
    association :choice, factory: :text_choice
  end

  factory :multiple_choice_response_matcher, parent: :response_matcher, class: "MultipleChoiceResponseMatcher" do
    association :choice, factory: :text_choice
  end

  factory :order_response_matcher, parent: :response_matcher, class: "OrderResponseMatcher" do
    association :first_place_choice, factory: :order_choice
  end
end