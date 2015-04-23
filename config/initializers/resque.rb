require 'resque-scheduler'
require 'resque/scheduler/server'

# configure redis connection
redis_url = ENV["REDISCLOUD_URL"] || "localhost:6379:resque/resque:#{Rails.env}"
Resque.redis = redis_url

# configure the schedule
resque_config = YAML.load_file(Rails.root.join('config', 'schedule.yml'))
Resque.schedule = resque_config if resque_config  # support servers without anything scheduled
