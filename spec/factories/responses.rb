# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :response do
    user
  end

  factory :image_response, parent: :response, class: "ImageResponse" do
    question {build :image_question}
    image
  end

  factory :text_response, parent: :response, class: "TextResponse" do
    question {build :text_question}
    text "A Text Response"
  end

  factory :choice_response, parent: :response, class: "ChoiceResponse" do
    question {build :choice_question}
  end

  factory :multiple_choice_response, parent: :response, class: "MultipleChoiceResponse" do
    question {build :multiple_choice_question}
  end

  factory :text_choice_response, parent: :response, class: "TextChoiceResponse" do
    question {build :text_choice_question}
    choice {build :text_choice}
  end

  factory :image_choice_response, parent: :response, class: "ImageChoiceResponse" do
    question {build :image_choice_question}
    choice {build :image_choice}
  end

  factory :star_response, parent: :response, class: "StarResponse" do
    question {build :star_question}
    stars 4
  end

  factory :percent_response, parent: :response, class: "PercentResponse" do
    question {build :percent_question}
    percent 25
  end

  factory :order_response, parent: :response, class: "OrderResponse" do
    question {build :order_question}
  end
end
