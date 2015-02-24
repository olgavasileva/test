FactoryGirl.define do
  factory :demographic do
    association :respondent, factory: :anonymous

    trait :quantcast do
      data_provider { DataProvider.find_by(name:"quantcast") || FactoryGirl.create(:data_provider, :quantcast) }
    end
  end
end
