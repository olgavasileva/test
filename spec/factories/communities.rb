FactoryGirl.define do
  factory :community do
    sequence(:name) { |n| "Software Developers #{n}" }
    user
  end

  factory :community_member do
    community
    user
  end
end
