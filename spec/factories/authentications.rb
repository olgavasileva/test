# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :authentication do
    user
    uid "uid"
    token "token"
    token_secret "secret"

    provider { Authentication::PROVIDERS.shuffle.first }

    trait :facebook do
      provider "facebook"
    end
  end
end
