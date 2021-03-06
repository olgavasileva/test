FactoryGirl.define do
  factory :instance do
    uuid {generate :uuid}
    device

    trait :can_push do
      push_app_name 'Konsensus'
      push_environment 'development'
      push_token {generate :apn_token}
    end

    trait :logged_out do
      user
    end

    trait :logged_in do
      user
      auth_token
    end

    trait :anon do
      user factory: :anonymous
    end
  end
end
