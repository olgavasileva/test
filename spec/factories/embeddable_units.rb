# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :embeddable_unit do
    association :survey, :embeddable
    thank_you_markdown "**Thanks for responding**"
  end
end
