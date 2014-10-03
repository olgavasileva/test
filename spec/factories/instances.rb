FactoryGirl.define do
  factory :instance do
    uuid {generate :uuid}
    device

    trait :can_push do
      push_app_name 'Konsensus'
      push_environment 'development'
      push_token {generate :apn_token}
    end

    trait :authorized do
      auth_token {generate :auth_token}
    end

    trait :unauthorized do
      auth_token nil
    end

    trait :logged_in do
      user
    end
  end
end