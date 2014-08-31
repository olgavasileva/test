FactoryGirl.define do
  factory :studio do
    name
    display_name {generate :name}
  end
end