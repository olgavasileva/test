# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :question do
    user
    category
    title {generate :name}
    description {generate :name}
  end

  factory :info_question, parent: :question, class: "InfoQuestion" do
    html "This is an info question"
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

  factory :multiple_choice_question, parent: :question, class: "MultipleChoiceQuestion" do
    rotate false
    min_responses 1
    max_responses 5
  end

  factory :star_question, parent: :question, class: "StarQuestion" do
    rotate false
    max_stars 5
  end

  factory :percent_question, parent: :question, class: "PercentQuestion" do
    rotate false
  end

  factory :order_question, parent: :question, class: "OrderQuestion" do
    rotate false
  end
end
