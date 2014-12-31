FactoryGirl.define do
  factory :user do
    name
    username
    email {generate :email_address}
    password "testing123"
    after(:build) {|user| user.password_confirmation ||= user.password}
    birthdate Date.current-20.years
    auth_token {generate :auth_token}

    trait :authorized do
      auth_token {generate :auth_token}
    end

    trait :unauthorized do
      auth_token nil
    end

    factory :authorized_user, traits: [:authorized]
  end

  factory :anonymous do
  end
end
