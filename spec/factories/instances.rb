FactoryGirl.define do
  factory :instance do
    uuid {generate :uuid}
    device

    trait :can_push do
      push_app_name 'Konsensus'
      push_environment 'development'
      push_token {generate :apn_token}
    end

    trait :logged_in do
      user factory: :authorized_user
    end
  end
end