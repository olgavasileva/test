# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :embeddable_unit do
    association :survey, factory: [:embeddable_survey]
  end
end
