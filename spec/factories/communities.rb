FactoryGirl.define do
  factory :community do
    sequence(:name) { |n| "Software Developers #{n}" }
    user
  end
end
