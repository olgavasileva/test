FactoryGirl.define do
  factory :user do
    name
    username
    email {generate :email_address}
    password "testing123"
    after(:build) {|user| user.password_confirmation ||= user.password}
    birthdate Date.current-20.years
  end

  factory :anonymous do
  end
end
