namespace :feed do
  desc "Ensure all user feeds have questions"
  task migrate: :environment do
    User.all.each do |user|
      if user.feed_items.empty?
        Question.active.publik.order("created_at ASC").each do |q|
          FeedItem.create! user:user, question:q, published_at:q.created_at
        end
      end
    end
  end
end
