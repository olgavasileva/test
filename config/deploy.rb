lock '3.4.0'

set :application, '2cents'
set :repo_url, 'git@github.com:FashionPlaytes/twocents.git'
set :ssh_options, { forward_agent:true, compression:"none" }
set :user, "deploy"
set :use_sudo, false

# rvm
set :rvm_ruby_version, 'ruby-2.1.1@global'
set :rvm_autolibs_flag, "read-only"       # more info: rvm help autolibs

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
set :deploy_to, "/app/#{fetch :application}"

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{config/database.yml config/application.yml}

# Default value for linked_dirs is []
set :linked_dirs, %w{log tmp/pids public/uploads}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 2

namespace :monit do
  task :summary do
    on roles(:app), in: :sequence, wait: 5 do
      sudo "monit summary"
    end
  end
end

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  task :restart_resque_workers do
    on roles(:app), in: :sequence, wait: 5 do
      sudo "monit restart all -g resque_workers"
    end
  end

  after :publishing, :restart
  after :publishing, :restart_resque_workers

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  after :finished, 'airbrake:deploy'

end