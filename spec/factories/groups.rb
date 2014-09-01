FactoryGirl.define do
  factory :group do
    sequence(:name) { |n| "Software Developers #{n}" }
    user
  end
end
