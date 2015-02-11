FactoryGirl.define do
  factory :user do
    name
    username
    email {generate :email_address}
    password "testing123"
    after(:build) {|user| user.password_confirmation ||= user.password}
    birthdate Date.current-20.years

    trait :pro do
      after :create do |u|
        u.add_role :pro
      end
    end
  end

  factory :anonymous do
  end

  factory :respondent do
  end
end
