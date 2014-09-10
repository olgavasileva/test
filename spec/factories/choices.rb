# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :choice_base, class:"Choice", aliases: [:choice] do
    title {generate :name}
    rotate false
  end

  factory :text_choice, parent: :choice_base, class:"TextChoice" do
    question {build :text_choice_question}
  end

  factory :image_choice, parent: :choice_base, class:"ImageChoice" do
    question {build :image_choice_question}
    association :background_image, factory: :choice_image
  end

  factory :multiple_choice, parent: :choice_base, class:"MultipleChoice" do
    question {build :multiple_choice_question}
    association :background_image, factory: :choice_image
  end

  factory :order_choice, parent: :choice_base, class:"OrderChoice" do
    question {build :order_question}
    association :background_image, factory: :order_choice_image
  end
end
