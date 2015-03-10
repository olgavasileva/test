# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :question do
    user
    category
    title {generate :name}
    state "active"
    association :background_image, factory: :question_image
    association :trend
  end

  factory :image_question, parent: :question, class: "ImageQuestion" do
  end

  factory :text_question, parent: :question, class: "TextQuestion" do
    text_type "freeform"
    min_characters 0
    max_characters 255
  end

  factory :choice_question, parent: :question, class: "ChoiceQuestion" do
    rotate false
  end

  factory :text_choice_question, parent: :choice_question, class: "TextChoiceQuestion" do
  end

  factory :image_choice_question, parent: :choice_question, class: "ImageChoiceQuestion" do
  end

  factory :multiple_choice_question, parent: :choice_question, class: "MultipleChoiceQuestion" do
    min_responses 1
    max_responses 5
  end

  factory :star_question, parent: :choice_question, class: "StarQuestion" do
    max_stars 5
  end

  factory :percent_question, parent: :choice_question, class: "PercentQuestion" do
  end

  factory :order_question, parent: :choice_question, class: "OrderQuestion" do
  end
end
