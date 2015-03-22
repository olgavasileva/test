FactoryGirl.define do
  factory :user do
    name
    username
    email {generate :email_address}
    password "testing123"
    password_confirmation { password }

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
