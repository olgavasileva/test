FactoryGirl.define do
  factory :user do
    sequence(:username)   { |n| "username_#{n}" }
    sequence(:name)       { |n| "Person #{n}" }
    sequence(:email)      { |n| "person_#{n}@example.com"}
    password "foobar69"
    password_confirmation "foobar69"

    factory :admin do
    	admin true
    end
  end

  factory :micropost do
  	content "Lorem ipsum"
  	user
  end

  factory :device do
    sequence(:udid) { |n| "NOT_A_REAL_UDID_#{n}" }
    device_type "iPad3,2"
    os_version "7.0.3"
  end

  factory :category do
    name "a test category"
  end

  factory :pack do
    title "Lorem ipsum"
    user
  end

  factory :comment do
    content "Lorem ipsum"
    user
    question
  end

  factory :sharing do
    question
  end
end