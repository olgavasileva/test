# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :choice_base, class:"Choice" do
    title {generate :name}
    rotate false
  end

  factory :text_choice, parent: :choice_base, class:"TextChoice" do
    question {build :text_choice_question}
  end

  factory :image_choice, parent: :choice_base, class:"ImageChoice" do
    question {build :image_choice_question}
    image
  end

  factory :multiple_choice, parent: :choice_base, class:"MultipleChoice" do
    question {build :multiple_choice_question}
  end
end
