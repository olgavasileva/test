# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :choice_base, class:"Choice" do
    title {generate :name}
    rotate false
  end

  factory :choice, parent: :choice_base do
    question {build :choice_question}
  end

  factory :multiple_choice, parent: :choice_base, class:"MultipleChoice" do
    question {build :multiple_choice_question}
  end
end
