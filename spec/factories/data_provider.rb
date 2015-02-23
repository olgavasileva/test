FactoryGirl.define do
  factory :data_provider do
    name

    trait :quantcast do
      name 'quantcast'
    end
  end
end
