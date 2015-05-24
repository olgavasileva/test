FactoryGirl.define do
  factory :respondent, aliases: [:follower, :leader] do
    username
  end

  factory :user do
    username
    name
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
    username
  end
end
