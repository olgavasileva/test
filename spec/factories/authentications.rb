# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :authentication do
    user
    uid { SecureRandom.uuid }
    token { SecureRandom.uuid }
    token_secret { SecureRandom.uuid }

    provider { Authentication::PROVIDERS.shuffle.first }

    trait :facebook do
      provider "facebook"
    end
  end
end
