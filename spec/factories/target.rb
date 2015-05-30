FactoryGirl.define do
  factory :consumer_target, aliases: [:target] do
    all_users false
    all_followers false
    all_groups false
    all_communities false
  end

  factory :enterprise_target do
    user
  end
end
