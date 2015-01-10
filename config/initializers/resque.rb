redis_url = ENV["REDISCLOUD_URL"] || "localhost:6379:resque/resque:#{Rails.env}"
Resque.redis = redis_url