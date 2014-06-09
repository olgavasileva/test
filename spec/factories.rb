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

  factory :question do
    title "Lorem ipsum dolor sit amet, consectetur adipisicing elit." 
    info "Perferendis, mollitia, atque, ipsa suscipit nemo praesentium laboriosam iste ex minima quisquam repellat unde reiciendis doloribus."
    question_type 1
    image_url "http://example.com/test.png"
    min_value -100
    max_value 100
    interval 2
    units "hr"
    user
    category
  end

  factory :choice do
    label "Lorem ipsum"
    image_url "http://example.com/test.png"
    description "consectetur adipisicing elit"
    question
  end

  factory :answer do
    agree true
    user
    question
  end

  factory :response do
    order 1
    percent 0.5
    star 3
    slider 50
    choice
    answer
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