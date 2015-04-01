FactoryGirl.define do
  factory :ad_unit do
    sequence(:name) { |n| "unit_#{n}" }
    width 300
    height 250
  end
end
