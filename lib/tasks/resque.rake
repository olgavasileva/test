require "resque/tasks"
require 'resque/scheduler/tasks'
require 'resque/pool/tasks'

task "resque:setup" => :environment do
  # generic worker setup, e.g. Hoptoad for failed jobs
end

task "resque:pool:setup" do
  # close any sockets or files in pool manager
  ActiveRecord::Base.connection.disconnect!
  # and re-open them in the resque worker parent
  Resque::Pool.after_prefork do |job|
    ActiveRecord::Base.establish_connection
    Resque.redis.client.reconnect
  end
end