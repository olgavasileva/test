namespace :feed do
  desc "Ensure all user feeds have questions"
  task migrate: :environment do
    User.all.each do |user|
      if user.feed_items.empty?
        user.reset_feed!
      end
    end
  end
end
